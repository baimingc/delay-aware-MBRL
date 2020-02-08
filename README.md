# Delay-Aware Model-Based Reinforcement Learning
<p align=center>
<img src="img/result.png" width=800>
</p>

**Abstract** Action delay prevalently exists in real world systems and is one of the key reasons leading to degraded performance of reinforcement learning. In this paper, we introduce a formal definition of delayed Markov Decision Process and prove it can be transformed into standard MDP with augmented states using Markov reward process. We then develop a delay-aware model-based reinforcement learning framework to directly incorporate the multi-step delay into the learned system models without learning effort. Experiments are conducted on the Gym and MuJoCo platforms. Results show that compared with off-policy model-free reinforcement learning methods, the proposed delay-aware model-based algorithm is more efficient in training and transferable between systems with variant durations of delay.

## Installation
This code-base is based on [PETS](https://github.com/kchua/handful-of-trials).
run ```pip install -r requirements.txt.``` to install the python dependency.
The current environments are simulated with MuJoCo 1.31. Please follow the installation procedures of MuJoCo + OpenAI gym, if the default pip installation fails.

# Run the code!
Below is an example to reproduce the results.

## DATS for pendulum with action delay
```
python mbexp.py -logdir ./log/DATS \
    -env gym_pendulum \
    -o exp_cfg.exp_cfg.ntrain_iters 200 \
    -o exp_cfg.sim_cfg.delay_hor 10\
    -o ctrl_cfg.prop_cfg.delay_step 10\
    -ca opt-type CEM \
    -ca model-type PE \
    -ca prop-type E
```

## Changing Hyper-parameters

This repo is based on the PETS repo. And therefore we use the same hyper-parameters / arguments system.

### Environment Arguments

The benchmark environment is based on [MBBL](https://github.com/WilsonWangTHU/mbbl)
```
python scripts/mbexp.py
    -env    (required) The name of the environment. Select from
            [reacher, pusher, halfcheetah, gym_ant, gym_cartpole, gym_fswimmer, ...].
```
Please look at ```./dmbrl/config``` for more environments.

### Control Arguments

```
python scripts/mbexp.py
-ca model-type   : Same as the one defined in PETS repo.
-ca prop-type    : Same as the one defined in PETS repo.
-ca opt-type     : The optimizer that will be used to select action sequences.
                   Select from [Random, CEM, POPLIN-A, POPLIN-P].
                   Make sure to select the correct opt-type before setting the other configs
```

### Other Arguments

All the old arguments are kept the same as they were in [PETS](https://github.com/kchua/handful-of-trials).
We refer the original code repo for the old arguments.
The new arguements are summarized as follows:

```
 ├──exp_cfg                                 - Experiment script configuration.
 │    ├── sim_cfg                           - Simulation configuration.
 │    ├── exp_cfg                           - Experiment configuration.
 │    │    └── ntrain_iters                 - Number of training iterations.
 │    │         
 │    └── log_cfg                           - Logger configuration.
 └── ctrl_cfg (MPC)                         - Controller configuration.
      │         
      ├── opt_cfg                           - Optimization configuration.
      │    ├── plan_hor                     - Planning horizon.
      │    ├── init_var                     - Initial variance of the CEM search.
      │    └── cfg                          - Optimizer configuration.
      │         ├── popsize    (ALL)        - Number of candidate solutions sampled (per iteration
      │         │                             for CEM).
      │         ├── max_iters  (ALL)        - Maximum number of optimization iterations.
      │         ├── num_elites (ALL)        - Number of elites used to refit Gaussian.
      │         └── epsilon    (ALL)        - Minimum variance for termination condition.
      │         
      └── cem_cfg                           - Other CEM config, especiailly the ones for POPLIN.
           ├── cem_type                     - Choose the variant of POPLIN to use
           │                                  ['POPLINA-INIT', 'POPLINA-REPLAN', (for POPLIN-A)
           │                                   'POPLINP-SEP', 'POPLINP-UNI'      (for POPLIN-P)]
           ├── training_scheme              - Choose the training schemse for the POPLIN
           │                                  ['BC-AR', 'BC-AI'                  (for POPLIN-A)
           │                                   'BC-PR', 'BC-PI'                  (for POPLIN-P)
           │                                   'AVG-R', 'AVG-I'                  (for POPLIN-P)
           │                                   'GAN-R', 'GAN-I'                  (for POPLIN-P)]
           ├── pct_testset                  - The percentage of data put into validation set.
           ├── policy_network_shape         - The shape of the policy network.
           │                                  Default is [64, 64]
           │                                  Recommended: [], [32], [64] (one hidden layer)
           ├── policy_epochs                - Epochs of training the policy network.
           ├── policy_lr                    - The learning rate to train the policy network.
           ├── policy_weight_decay          - Weight decay applied to the policy network.
           ├── minibatch_size               - The batchsize of training policy network.
           ├── test_policy                  - If set to 1, the agent will generate policy control
           │                                  results. Not appliable for POPLIN-A or PETS.
           └── discriminator*               - The configs for training the discrimnator for
                                              POPLIN-P-GAN. Similar to the ones of policy network.
```

To set these parameters, follow the below example scripts for POPLINA-P:
```
python mbexp.py -logdir ./log/POPLINP_AVG -env halfcheetah \
    -o exp_cfg.exp_cfg.ntrain_iters 50 \
    -o ctrl_cfg.cem_cfg.cem_type POPLINP-SEP \
    -o ctrl_cfg.cem_cfg.training_scheme AVG-R \
    -o ctrl_cfg.cem_cfg.policy_network_shape [32] \
    -o ctrl_cfg.opt_cfg.init_var 0.1 \
    -o ctrl_cfg.cem_cfg.test_policy 1 \
    -ca model-type PE -ca prop-type E \
    -ca opt-type POPLIN-P
```

# Results Logger

Results will be saved in `<logdir>/<date+time of experiment start>/logs.mat`.
Besides the original contents, we also have the ```test_return``` data in the result mat.
```
{"observations":            the observation generated in the training
 "actions":                 the actions generated in the training
 "rewards":                 the rewards generated in the training
 "returns":                 the return of MPC-control
 "test_returns":            the return of policy-control}
```

The logging file generated during the training can be observed in ```<logdir>/*/*.log/logger.log```.
