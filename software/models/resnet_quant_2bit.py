'''
2-bit ResNet-20 for CIFAR-10 (HW5 Q1-B), based on resnet_quant.py.

Differences from resnet_quant.py:
- every quantized conv (both convs in each BasicBlock and the 1x1 downsample convs) is 2-bit
  (QuantConv2d_nbit from quant_layer_2bit.py, bit=2)
- the first conv layer is quantized too (2-bit), with its activation clipping value initialized to 2.0:
  its input is the normalized image (about -2 to 2.1), and with the default 8.0 the 2-bit step would be
  8/3 = 2.7, so most pixels would round to 0 and act_alpha would get no gradient (nothing is clipped)
- the last FC layer stays full precision
'''

import torch
import torch.nn as nn
import math
from models.quant_layer_2bit import QuantConv2d_nbit

BIT = 2


def Quantconv3x3(in_planes, out_planes, stride=1):
    " 3x3 quantized convolution with padding "
    return QuantConv2d_nbit(in_planes, out_planes, kernel_size=3, stride=stride, padding=1, bias=False, bit=BIT)


class BasicBlock(nn.Module):
    expansion=1

    def __init__(self, inplanes, planes, stride=1, downsample=None):
        super(BasicBlock, self).__init__()
        self.conv1 = Quantconv3x3(inplanes, planes, stride)
        self.bn1 = nn.BatchNorm2d(planes)
        self.relu = nn.ReLU(inplace=True)
        self.conv2 = Quantconv3x3(planes, planes)
        self.bn2 = nn.BatchNorm2d(planes)
        self.downsample = downsample
        self.stride = stride

    def forward(self, x):
        residual = x
        out = self.conv1(x)
        out = self.bn1(out)
        out = self.relu(out)

        out = self.conv2(out)
        out = self.bn2(out)

        if self.downsample is not None:
            residual = self.downsample(x)

        out += residual
        out = self.relu(out)

        return out


class ResNet_Cifar_2bit(nn.Module):

    def __init__(self, block, layers, num_classes=10):
        super(ResNet_Cifar_2bit, self).__init__()
        self.inplanes = 16
        # first conv layer: 2-bit as well, act_alpha starts at 2.0 to match the normalized image range
        self.conv1 = QuantConv2d_nbit(3, 16, kernel_size=3, stride=1, padding=1, bias=False, bit=BIT, act_alpha=2.0)
        self.bn1 = nn.BatchNorm2d(16)
        self.relu = nn.ReLU(inplace=True)
        self.layer1 = self._make_layer(block, 16, layers[0])
        self.layer2 = self._make_layer(block, 32, layers[1], stride=2)
        self.layer3 = self._make_layer(block, 64, layers[2], stride=2)
        self.avgpool = nn.AvgPool2d(8, stride=1)
        self.fc = nn.Linear(64 * block.expansion, num_classes)   # last FC layer: full precision

        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                n = m.kernel_size[0] * m.kernel_size[1] * m.out_channels
                m.weight.data.normal_(0, math.sqrt(2. / n))
            elif isinstance(m, nn.BatchNorm2d):
                m.weight.data.fill_(1)
                m.bias.data.zero_()

    def _make_layer(self, block, planes, blocks, stride=1):
        downsample = None
        if stride != 1 or self.inplanes != planes * block.expansion:
            downsample = nn.Sequential(
                QuantConv2d_nbit(self.inplanes, planes * block.expansion, kernel_size=1, stride=stride, bias=False,
                                 bit=BIT),
                nn.BatchNorm2d(planes * block.expansion)
            )

        layers = []
        layers.append(block(self.inplanes, planes, stride, downsample))
        self.inplanes = planes * block.expansion
        for _ in range(1, blocks):
            layers.append(block(self.inplanes, planes))

        return nn.Sequential(*layers)

    def forward(self, x):
        x = self.conv1(x)
        x = self.bn1(x)
        x = self.relu(x)

        x = self.layer1(x)
        x = self.layer2(x)
        x = self.layer3(x)

        x = self.avgpool(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)

        return x

    def show_params(self):
        for m in self.modules():
            if isinstance(m, QuantConv2d_nbit):
                m.show_params()


def resnet20_quant_2bit(**kwargs):
    model = ResNet_Cifar_2bit(BasicBlock, [3, 3, 3], **kwargs)
    return model
