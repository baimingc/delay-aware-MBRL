#!/bin/bash
python mbexp.py -logdir ./log/DATS \
    -env gym_pendulum \
    -o exp_cfg.exp_cfg.ntrain_iters 200 \
    -o exp_cfg.sim_cfg.delay_hor 10\
    -o ctrl_cfg.prop_cfg.delay_step 10\
    -ca opt-type CEM \
    -ca model-type PE \
    -ca prop-type E
