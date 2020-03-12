#!/usr/bin/env python

import os

from setuptools import setup, find_packages

requires = [
  'bottle',
]

setup(name='xeraweb_hello',
  version='1.0.0',
  description='Hello World with the current hostname',
  packages=find_packages(),
  install_requires=requires,
  entry_points={
    'console_scripts': [
      'xeraweb-service = xeraweb_hello.service:main',
    ],
  },
)
