#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# nblog - simple microblogging thing

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'application'

NBlog::Application.run! if __FILE__ == $PROGRAM_NAME
