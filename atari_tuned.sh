#!/bin/bash

# you may have to execute this cmd:
# $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/<user>/.mujoco/mujoco200/bin

# static configs
PYTHON=python
EXPERIMENT="atari"
NUM_STEPS="10000000"

if [ $EXPERIMENT = "mujoco" ]
then
	echo using mujoco hyperparameters 
	HORIZON="2048"
	ADAM_STEPSIZE="0.0003"
	NUM_EPOCHS="10"
	MINIBATCH_SIZE="64"
	DISCOUNT="0.99"
	GAE_PARAMETER="0.95"
	net="mlp"
elif [ $EXPERIMENT = "atari" ]
then
	HORIZON="128"
	NUM_EPOCHS="3"
	MINIBATCH_SIZE="32"
	DISCOUNT="0.99"
	GAE_PARAMETER="0.95"
	VF="1"
	ENT="0.01"	
	net="cnn"
else
	echo ERROR@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
fi

# dynamic configs
# ENVS_ATARI=( "MsPacmanNoFrameskip-v4" "PongNoFrameskip-v4" "SpaceInvadersNoFrameskip-v4" "MontezumaRevengeNoFrameskip-v4" )
ENVS_ATARI=( "MontezumaRevengeNoFrameskip-v4" )
ALGS=( "ppo2" "a2c" )

# run experiments
for env in "${ENVS_ATARI[@]}"
do
	for alg in "${ALGS[@]}"
	do
		if [ $EXPERIMENT = "mujoco" ] && [ $alg = "ppo2" ]
		then
			echo running ppo-mujoco
			$PYTHON -m baselines.run --alg=$alg --env=$env --network=$net --nsteps=$HORIZON --lr=$ADAM_STEPSIZE --noptepochs=$NUM_EPOCHS --nminibatches=$MINIBATCH_SIZE --gamma=$DISCOUNT --lam=$GAE_PARAMETER --num_timesteps=$NUM_STEPS --save_path="~/models_new/${env}_${alg}_${NUM_STEPS}" --log_path="~/logs_rl_new/${env}_${alg}_${NUM_STEPS}"
		elif [ $EXPERIMENT = "atari" ] && [ $alg = "ppo2" ]
		then
			echo running ppo-atari 
			$PYTHON -m baselines.run --alg=$alg --env=$env --network=$net --vf_coef=$VF --ent_coef=$ENT --nsteps=$HORIZON --noptepochs=$NUM_EPOCHS --nminibatches=$MINIBATCH_SIZE --gamma=$DISCOUNT --lam=$GAE_PARAMETER --num_timesteps=$NUM_STEPS --save_path="~/models_new/${env}_${alg}_${NUM_STEPS}" --log_path="~/logs_rl_new/${env}_${alg}_${NUM_STEPS}"
		else
			echo running baseline
			$PYTHON -m baselines.run --alg=$alg --env=$env --network=$net --num_timesteps=$NUM_STEPS --save_path="~/models_new/${env}_${alg}_${NUM_STEPS}" --log_path="~/logs_rl_new/${env}_${alg}_${NUM_STEPS}"
		fi
	done
done
