classdef (Abstract) Hierarchical1 < Model
	%Hierarchical1  Hierarchical1 is a subclass of Model for examining the 1-parameter hyperbolic discounting function.

	properties (Access = private)
		getDiscountRate % function handle
	end

	methods (Access = public)

		function obj = Hierarchical1(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelFilename		= 'hierarchicalLogK';
			obj.discountFuncType = 'hyperbolic1';
			obj.getDiscountRate = @getLogDiscountRate; % <-------------------------------------- FINISH

			% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			obj.varList.monitored = {'logk','alpha','epsilon', 'Rpostpred', 'P'};

			% obj = obj.addUnobservedParticipant('GROUP');

			%% Plotting
			obj.experimentFigPlotFuncs		= make_experimentFigPlotFuncs_LogK();
			obj.plotFuncs.clusterPlotFunc	= @plotLOGKclusters;

		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

	end

	
	methods (Abstract)
		setInitialParamValues
    end

end