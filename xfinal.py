#!/usr/bin/python3

# Gabriel Ehrlich
# Matt Staib
# Final Project
# AA 203
# Spring 2015

import numpy as np, matplotlib.pylab as plt

def x_final(feasible, target, w, Delta):
	"""Return a maximal control invariant X_f.

	Parameters:
	    feasible: a np.array of np._bools in which feasible points are True
	    target: a np.array of np._bools in which target points are True. Must
	        be same shape as feasible
	    w: the noise term. A function x -> PDF(x).
	    Delta: a float representing maximum allowable risk
	Returns:
	    x_final: a np.array of np.float64s. x_final[i, j] is the maximum
	        allowable risk such that a trajectory starting at x_ij with that
	        much accumulated risk can reach the target point within the
	        constraint E(sum(I(x_i))|x_0 = x_ij) <=  Delta.
	"""
	pass