#!/usr/bin/env ruby

require_relative 'lisp'

fn = [:lambda, ["a", "b", "c"], exec_one("5")]

p fn
