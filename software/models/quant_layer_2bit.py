'''
Quantized conv layer with a configurable bit width (HW5 Q1-B).

QuantConv2d in quant_layer.py fixes self.bit = 4 and builds both quantizers from it. This layer takes
the bit width as an argument instead (default 2), so the quantizers are created with the right number of
levels when the model is built. The quantization functions themselves are reused from quant_layer.py.

2-bit: weights -> {-1, 0, 1} x delta_w (1 sign bit + 1 magnitude level), activations -> {0, 1, 2, 3} x delta_x.
'''

import torch
import torch.nn as nn
import torch.nn.functional as F
from models.quant_layer import weight_quantize_fn, act_quantization


class QuantConv2d_nbit(nn.Conv2d):
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0, dilation=1, groups=1, bias=False,
                 bit=2, act_alpha=8.0):
        super(QuantConv2d_nbit, self).__init__(in_channels, out_channels, kernel_size, stride, padding, dilation,
                                               groups, bias)
        self.layer_type = 'QuantConv2d_nbit'
        self.bit = bit
        self.weight_quant = weight_quantize_fn(w_bit=self.bit)
        self.act_alq = act_quantization(self.bit)
        # initial activation clipping value; the first conv layer needs a smaller one (see resnet_quant_2bit.py)
        self.act_alpha = torch.nn.Parameter(torch.tensor(float(act_alpha)))
        self.weight_q  = torch.nn.Parameter(torch.zeros([out_channels, in_channels, kernel_size, kernel_size]))

    def forward(self, x):
        weight_q = self.weight_quant(self.weight)
        self.weight_q = torch.nn.Parameter(weight_q)  # Store weight_q during the training
        x = self.act_alq(x, self.act_alpha)
        return F.conv2d(x, weight_q, self.bias, self.stride, self.padding, self.dilation, self.groups)

    def extra_repr(self):
        return super(QuantConv2d_nbit, self).extra_repr() + ', bit={}'.format(self.bit)

    def show_params(self):
        wgt_alpha = round(self.weight_quant.wgt_alpha.data.item(), 3)
        act_alpha = round(self.act_alpha.data.item(), 3)
        print('clipping threshold weight alpha: {:2f}, activation alpha: {:2f}'.format(wgt_alpha, act_alpha))
