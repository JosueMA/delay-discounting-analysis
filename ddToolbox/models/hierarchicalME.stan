// JAGS model of temporal discounting behaviour// - 1-parameter hyperbolic discount function// - magnitude effect// - hierarchical: estimates participant- and group-level parameters// functions {// }data {  int <lower=1> totalTrials;  int <lower=1> nParticipants;  int <lower=1> T[nParticipants];  real A[totalTrials];  real B[totalTrials];  real <lower=0> DA[totalTrials];  real <lower=0> DB[totalTrials];  int <lower=0,upper=1> R[totalTrials];  int <lower=1,upper=nParticipants> ID[totalTrials];}parameters {  // group level  real groupMmu;  real <lower=0> groupMsigma;  real groupCmu;  real <lower=0> groupCsigma;  real groupALPHAmu;  real <lower=0> groupALPHAsigma;  real <lower=0,upper=1>groupW;  real groupKminus2;  // participant level  real m[nParticipants];  real c[nParticipants];  real <lower=0> epsilon[nParticipants];  real <lower=0,upper=0.5> alpha[nParticipants];}transformed parameters {  // group LEVEL  real groupK;  real lkA[totalTrials];  real lkB[totalTrials];  real VA[totalTrials];  real VB[totalTrials];  real P[totalTrials];  groupK <- groupKminus2+2;  for (t in 1:totalTrials){ // TODO Can this be vectorized?    // Calculate log discount rate for each reward    lkA[t] <- m[ID[t]]*log(fabs(A[t]))+c[ID[t]];    lkB[t] <- m[ID[t]]*log(fabs(B[t]))+c[ID[t]];    // calculate present subjective value for each reward    VA[t] <- A[t] / (1+(exp(lkA[t])*DA[t]));    VB[t] <- B[t] / (1+(exp(lkB[t])*DB[t]));    // Psychometric function    P[t] <- epsilon[ID[t]] + (1-2*epsilon[ID[t]]) * Phi( (VB[t]-VA[t]) / alpha[t] );  }}model {  // GROUP LEVEL PRIORS ======================================================  groupMmu        ~ normal(-0.243, (0.027*10)^2);  groupMsigma     ~ normal( 0.072, (0.025*10)^2); // truncated >0  groupCmu        ~ normal(0, (10000^2));  groupCsigma     ~ uniform(0, 10000);  groupALPHAmu    ~ uniform(0,1000);  groupALPHAsigma ~ uniform(0,1000);  groupW          ~ beta(1.1, 10.9);  // mode for lapse rate  groupKminus2    ~ gamma(0.01,0.01); // concentration parameter  // PARTICIPANT LEVEL =======================================================  for (p in 1:nParticipants){ // TODO Can this be vectorized?    // magnitide effect (m,c) for each person    m[p]        ~ normal(groupMmu, groupMsigma^2);    c[p]        ~ normal(groupCmu, groupCsigma^2);    epsilon[p]  ~ beta(groupW*(groupK-2)+1 , (1-groupW)*(groupK-2)+1 );    alpha[p]    ~ normal(groupALPHAmu, groupALPHAsigma^2);  }  // TODO: Should be able to vectorize this  for (t in 1:totalTrials){    R[t] ~ bernoulli(P[t]);          // response  }}generated quantities { // see page 76 of manual  real m_group;  real c_group;  real <lower=0> alpha_group;  real <lower=0,upper=0.5> epsilon_group;  real m_group_prior;  real c_group_prior;  real <lower=0> alpha_group_prior;  real <lower=0,upper=0.5> epsilon_group_prior;  int <lower=0,upper=1> Rpostpred[totalTrials];  // samples from the priors  real groupMmuprior;  real <lower=0> groupMsigmaprior;  real groupCmuprior;  real <lower=0> groupCsigmaprior;  real <lower=0> groupALPHAmuprior;  real <lower=0> groupALPHAsigmaprior;  real <lower=0,upper=1> groupWprior;  real groupKminus2prior;  real groupKprior;  // group level posterior predictive distributions  m_group       <- normal_rng(groupMmu, groupMsigma^2);  c_group       <- normal_rng(groupCmu, groupCsigma^2);  alpha_group   <- normal_rng(groupALPHAmu, groupALPHAsigma^2);  epsilon_group <- beta_rng(groupW*(groupK-2)+1 , (1-groupW)*(groupK-2)+1 );  // samples from the priors  m_group_prior       <- normal_rng(groupMmuprior, groupMsigmaprior^2);  c_group_prior       <- normal_rng(groupCmuprior, groupCsigmaprior^2);  alpha_group_prior   <- normal_rng(groupALPHAmuprior, 1/(groupALPHAsigmaprior^2));  epsilon_group_prior <- beta_rng(groupWprior*(groupKprior-2)+1 , (1-groupWprior)*(groupKprior-2)+1 );  // samples from the priors  groupMmuprior         <- normal_rng(-0.243, (0.027*10)^2);  groupMsigmaprior      <- normal_rng( 0.072, (0.025*10)^2); // truncated >0  groupCmuprior         <- normal_rng(0, 10000^2);  groupCsigmaprior      <- uniform_rng(0, 10000);  groupALPHAmuprior     <- uniform_rng(0,1000);  groupALPHAsigmaprior  <- uniform_rng(0,1000);  groupWprior           <- beta_rng(1.1, 10.9); // mode for lapse rate  groupKminus2prior     <- gamma_rng(0.01,0.01); // concentration parameter  groupKprior <- groupKminus2prior+2;  // posterior predictive of response  for (t in 1:totalTrials){    Rpostpred[t] <- bernoulli_rng(P[t]);  // posterior predictive  }}