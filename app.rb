#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# nblog - simple microblogging thing

$:.unshift File.expand_path("../lib", __FILE__)

require "application"

NBlog::Application.run!