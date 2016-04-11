#!/usr/bin/env python3

import re
import unittest
import subprocess
import time
import argparse
import os


def xrandr(*args):
    return subprocess.check_output(
        ['xrandr'] + list(args)
    ).decode('utf-8')


class XRandrMunger:
    def __init__(self, input):
        self.input = input
        self._lines = None
        self._port_lines = None
        self._ports = None

    def ports_to_configure(self):
        return [port for (port, state) in self.ports().items() if
                state['connected'] and state['resolution'] is None]

    def ports_to_disable(self):
        return [port for (port, state) in self.ports().items() if
                not state['connected'] and state['resolution'] is not None]

    def ports(self):
        def resparse(match):
            if match.group('XRes') is None:
                return None
            else:
                return (
                    int(match.group('XRes')),
                    int(match.group('YRes')),
                    int(match.group('XOff')),
                    int(match.group('YOff'))
                )

        def dimparse(match):
            if match.group('XDim') is None:
                return None
            else:
                return (
                    int(match.group('XDim')),
                    int(match.group('YDim'))
                )

        if self._ports is None:
            self._ports = {
                match.group('port'): {
                    'connected': match.group('connection') == 'connected',
                    'resolution': resparse(match),
                    'dimensions': dimparse(match)
                } for match in self.parsed_port_lines()
            }
        return self._ports

    def parsed_port_lines(self):
        parser = re.compile('^(?P<port>[a-zA-Z0-9-]+) '
                            '(?P<connection>(dis)?connected) '
                            '((?P<XRes>[0-9]+)x(?P<YRes>[0-9]+)'
                            '\+(?P<XOff>[0-9]+)\+(?P<YOff>[0-9]+))?'
                            '( \((?P<Orientation>[a-z ]*)\))? ?'
                            '((?P<XDim>[0-9]+)mm x (?P<YDim>[0-9]+)mm)?'
                            '.*')
        return [parser.match(line) for line in self.port_lines()]

    def port_lines(self):
        if self._port_lines is None:
            self._port_lines = [
                l for l in self.lines()
                if not l.startswith("Screen ") and
                not l.startswith(" ")
            ]
        return self._port_lines

    def lines(self):
        if self._lines is None:
            self._lines = [line for line in self.input.split("\n")
                           if not line.strip() == ""]
        return self._lines


class XRandrMungerTestCase(unittest.TestCase):
    def setUp(self):
        self.maxDiff = None

    def test_ports_to_configure_internal_only(self):
        m = XRandrMunger(self.input('InternalDisplay'))
        self.assertEqual(m.ports_to_configure(), [])

    def test_ports_to_configure_connected_not_configured(self):
        m = XRandrMunger(self.input('AcerConnectedNotConfigured'))
        self.assertEqual(m.ports_to_configure(), ['DP-0'])

    def test_ports_to_configure_connected_configured(self):
        m = XRandrMunger(self.input('AcerConnectedConfigured'))
        self.assertEqual(m.ports_to_configure(), [])

    def test_ports_to_configure_not_connected_configured(self):
        m = XRandrMunger(self.input('AcerNotConnectedConfigured'))
        self.assertEqual(m.ports_to_configure(), [])

    def test_ports_to_disable_internal_only(self):
        m = XRandrMunger(self.input('InternalDisplay'))
        self.assertEqual(m.ports_to_disable(), [])

    def test_ports_to_disable_connected_not_configured(self):
        m = XRandrMunger(self.input('AcerConnectedNotConfigured'))
        self.assertEqual(m.ports_to_disable(), [])

    def test_ports_to_disable_connected_configured(self):
        m = XRandrMunger(self.input('AcerConnectedConfigured'))
        self.assertEqual(m.ports_to_disable(), [])

    def test_ports_to_disable_not_connected_configured(self):
        m = XRandrMunger(self.input('AcerNotConnectedConfigured'))
        self.assertEqual(m.ports_to_disable(), ['DP-0'])

    def test_parsed_lines_just_internal_display(self):
        m = XRandrMunger(self.input('InternalDisplay'))
        self.assertEqual(m.ports(), {
            'DP-0': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-1': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'HDMI-0': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-2': {
                'connected': True,
                'resolution': (2880, 1800, 0, 0),
                'dimensions': (331, 207)
            },
            'DP-3': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-4': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            }
        })

    def test_parsed_lines_connected_not_configured(self):
        m = XRandrMunger(self.input('AcerConnectedNotConfigured'))
        self.assertEqual(m.ports(), {
            'DP-0': {
                'connected': True,
                'resolution': None,
                'dimensions': None
            },
            'DP-1': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'HDMI-0': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-2': {
                'connected': True,
                'resolution': (2880, 1800, 0, 0),
                'dimensions': (331, 207)
            },
            'DP-3': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-4': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            }
        })

    def test_parsed_lines_connected_configured(self):
        m = XRandrMunger(self.input('AcerConnectedConfigured'))
        self.assertEqual(m.ports(), {
            'DP-0': {
                'connected': True,
                'resolution': (1920, 1080, 2880, 0),
                'dimensions': (531, 299)
            },
            'DP-1': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'HDMI-0': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-2': {
                'connected': True,
                'resolution': (2880, 1800, 0, 0),
                'dimensions': (331, 207)},
            'DP-3': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-4': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            }
        })

    def test_parsed_lines_not_connected_configured(self):
        m = XRandrMunger(self.input('AcerNotConnectedConfigured'))
        self.assertEqual(m.ports(), {
            'DP-0': {
                'connected': False,
                'resolution': (1920, 1080, 2880, 0),
                'dimensions': (0, 0)
            },
            'DP-1': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'HDMI-0': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-2': {
                'connected': True,
                'resolution': (2880, 1800, 0, 0),
                'dimensions': (331, 207)
            },
            'DP-3': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            },
            'DP-4': {
                'connected': False,
                'resolution': None,
                'dimensions': None
            }
        })

    def test_port_lines(self):
        m = XRandrMunger(self.input('InternalDisplay'))
        self.assertEqual(m.port_lines(), [
            'DP-0 disconnected (normal left inverted right x axis y axis)',
            'DP-1 disconnected (normal left inverted right x axis y axis)',
            'HDMI-0 disconnected (normal left inverted right x axis y axis)',
            'DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm',  # noqa
            'DP-3 disconnected (normal left inverted right x axis y axis)',
            'DP-4 disconnected primary (normal left inverted right x axis y axis)'  # noqa
        ])

    def test_port_lines_connected_configured(self):
        m = XRandrMunger(self.input('AcerConnectedConfigured'))
        self.assertEqual(m.port_lines(), [
            'DP-0 connected 1920x1080+2880+0 (normal left inverted right x axis y axis) 531mm x 299mm',  # noqa
            'DP-1 disconnected (normal left inverted right x axis y axis)',
            'HDMI-0 disconnected (normal left inverted right x axis y axis)',
            'DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm',  # noqa
            'DP-3 disconnected (normal left inverted right x axis y axis)',
            'DP-4 disconnected primary (normal left inverted right x axis y axis)'  # noqa
        ])

    def test_lines(self):
        m = XRandrMunger(self.input('InternalDisplay'))
        self.assertEqual(m.lines(), [
            'Screen 0: minimum 8 x 8, current 2880 x 1800, maximum 16384 x 16384',  # noqa
            'DP-0 disconnected (normal left inverted right x axis y axis)',
            'DP-1 disconnected (normal left inverted right x axis y axis)',
            'HDMI-0 disconnected (normal left inverted right x axis y axis)',
            'DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm',  # noqa
            '   2880x1800     59.99*+',
            'DP-3 disconnected (normal left inverted right x axis y axis)',
            'DP-4 disconnected primary (normal left inverted right x axis y axis)',  # noqa
        ])

    def input(self, case):  # noqa
        input = {}
        input['InternalDisplay'] = '''
Screen 0: minimum 8 x 8, current 2880 x 1800, maximum 16384 x 16384
DP-0 disconnected (normal left inverted right x axis y axis)
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-0 disconnected (normal left inverted right x axis y axis)
DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm
   2880x1800     59.99*+
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 disconnected primary (normal left inverted right x axis y axis)
'''  # noqa
        input['AcerConnectedNotConfigured'] = '''
Screen 0: minimum 8 x 8, current 2880 x 1800, maximum 16384 x 16384
DP-0 connected (normal left inverted right x axis y axis)
   1920x1080     60.00 +
   1680x1050     59.95
   1440x900      59.89
   1280x1024     75.02    60.02
   1280x960      60.00
   1280x800      59.81
   1280x720      60.00
   1152x864      75.00
   1024x768      75.03    70.07    60.00
   800x600       75.00    72.19    60.32    56.25
   640x480       75.00    72.81    59.94
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-0 disconnected (normal left inverted right x axis y axis)
DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm
   2880x1800     59.99*+
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 disconnected primary (normal left inverted right x axis y axis)
'''  # noqa
        input['AcerConnectedConfigured'] = '''
Screen 0: minimum 8 x 8, current 4800 x 1800, maximum 16384 x 16384
DP-0 connected 1920x1080+2880+0 (normal left inverted right x axis y axis) 531mm x 299mm
   1920x1080     60.00*+
   1680x1050     59.95
   1440x900      59.89
   1280x1024     75.02    60.02
   1280x960      60.00
   1280x800      59.81
   1280x720      60.00
   1152x864      75.00
   1024x768      75.03    70.07    60.00
   800x600       75.00    72.19    60.32    56.25
   640x480       75.00    72.81    59.94
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-0 disconnected (normal left inverted right x axis y axis)
DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm
   2880x1800     59.99*+
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 disconnected primary (normal left inverted right x axis y axis)
'''  # noqa
        input['AcerNotConnectedConfigured'] = '''
Screen 0: minimum 8 x 8, current 4800 x 1800, maximum 16384 x 16384
DP-0 disconnected 1920x1080+2880+0 (normal left inverted right x axis y axis) 0mm x 0mm
DP-1 disconnected (normal left inverted right x axis y axis)
HDMI-0 disconnected (normal left inverted right x axis y axis)
DP-2 connected 2880x1800+0+0 (normal left inverted right x axis y axis) 331mm x 207mm
   2880x1800     59.99*+
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 disconnected primary (normal left inverted right x axis y axis)
  1920x1080 (0x27f) 148.500MHz
        h: width  1920 start 2008 end 2052 total 2200 skew    0 clock  67.50KHz
        v: height 1080 start 1084 end 1089 total 1125           clock  60.00Hz
'''  # noqa
        return input[case]

if __name__ == "__main__":
    if os.environ.get('DO_TEST'):
        unittest.main()
    else:
        parser = argparse.ArgumentParser()
        parser.add_argument('--delay', default=15,
                            help='How often to check for xrandr changes')
        parser.add_argument('--once', help='Only check for changes once',
                            action='store_true')
        parser.add_argument('--primary', help='Primary display to reference')
        parser.add_argument('--side', choices=['right', 'left'],
                            help='Relation of new monitors to primary')

        args = parser.parse_args()

        while True:
            munger = XRandrMunger(xrandr())
            [xrandr('--output', port, '--off')
             for port in munger.ports_to_disable()]

            [xrandr('--output', port,
                    '--{side}-of'.format(side=args.side),
                    args.primary, '--auto')
             for port in munger.ports_to_configure()]
            if args.once:
                break

            time.sleep(int(args.delay))
