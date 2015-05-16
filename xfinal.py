#!/usr/bin/python3

# Gabriel Ehrlich
# Matt Staib
# Final Project
# AA 203
# Spring 2015

import numpy as np, matplotlib.pylab as plt
from Queue import Queue

def x_final(feasible, target, w, Delta):
    """Return a maximal control invariant X_f.

    Parameters:
        feasible: a np.array of np._bools in which feasible points are True
        target: a np.array of np._bools in which target points are True. Must
            be same shape as feasible
        w: a discretization of the noise term: x, y, ..., z -> P(x, y, ..., z).
        Delta: a float representing maximum allowable risk
    Returns:
        x_final: a np.array of np.float64s. x_final[i, j] is the maximum
            allowable risk such that a trajectory starting at x_ij with that
            much accumulated risk can reach the target point within the
            constraint E(sum(I(x_i))|x_0 = x_ij) <=  Delta.
    """
    # Make sure there's at least one target
    assert np.any(target == 1)

    # Initialize array with known values
    x_final = feasible + Delta*target

    # TODO: make this a generator or something sensible
    q = tuple(i, j for i,j in target[target == 1])
    # Store calculated values (i, j): cost in this dict
    d = {}
    # Initialize an array to deal with noise
    destination_prob = np.zeros(x_final.shape)
    # Create arrays of x, y, ..., z indices for repeated use
    grid = np.indices(x_final)
    # Do DP. Work from target backwards, adding progressively more distant
    # points to the queue.
    # TODO: generalize to n dimensions
    for i, j in q:
        # For each possible control,
        for u_i, u_j in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            # Check if it's farther from a target point (i.e. not already
            # calculated and not a candidate for a previous step)
            if (i + u_i, j + u_j) not in d: continue
            # calc probs of each possible actual next destination
            destination_prob[:] = w(i_grid, j_grid)
            # calc min expected value of risk
        # store minimum of optoins in d
        # add not-already-calculated neighbors to q
        pass