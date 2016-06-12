classdef ModelMixedLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)
		% =================================================================
		function obj = ModelMixedLogK(toolboxPath, samplerType, data, saveFolder, varargin)
			obj = obj@Model(data, saveFolder, varargin{:});

			switch samplerType
				case{'JAGS'}
					modelPath = '/models/mixedLogK.txt';
					obj.sampler = MatjagsWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
				case{'STAN'}
					error('model not implemented in STAN.')
					modelPath = '/models/hierarchicalLogK.stan';
					obj.sampler = MatlabStanWrapper([toolboxPath modelPath]);
					[~,obj.modelType,~] = fileparts(modelPath);
			end
			obj.discountFuncType = 'logk';
			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;

			%% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
            obj.varList.participantLevelPriors = {'logk_group_prior','alpha_group_prior','epsilon_group_prior'};
			obj.varList.groupLevel = {'logk_group','alpha_group','epsilon_group'};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_group','alpha_group','epsilon_group',...
				'logk_group_prior','epsilon_group_prior','alpha_group_prior',...
				'groupW','groupK','groupALPHAmu','groupALPHAsigma',...
				'groupLogKmu_prior', 'groupLogKsigma_prior','groupW_prior','groupK_prior','groupALPHAmu_prior','groupALPHAsigma_prior',...
				'Rpostpred'};

			%% Deal with generating initial values of leaf nodes
% 			obj.variables.groupLogKmu = Variable('groupLogKmu',...
% 				'seed', @() normrnd(-0.243,5),...
% 				'single',true);
% 			obj.variables.groupLogKsigma = Variable('groupLogKsigma',...
% 				'seed', @() rand*10,...
% 				'single',true);

			obj.variables.groupW = Variable('groupW','single',true,...
				'seed', @() rand);
			obj.variables.groupK = Variable('groupK','single',true); % TODO: SHOULD BE groupKminus2 !!

			obj.variables.groupALPHAmu = Variable('groupALPHAmu',...
				'seed', @() rand*100,...
				'single',true);
			obj.variables.groupALPHAsigma = Variable('groupALPHAsigma',...
				'seed', @() rand*100,...
				'single',true);

		end
		% =================================================================

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end


	end

end
