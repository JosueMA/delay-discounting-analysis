classdef ModelMixedHyperboloid < Hyperboloid
	%ModelMixedHyperboloid A model to estimate the log discount rate, according to the 2-parameter hyperboloid discount function.
	%  SOME parameters are estimated hierarchically.

	methods (Access = public, Hidden = true)
		function obj = ModelMixedHyperboloid(data, varargin)
			obj = obj@Hyperboloid(data, varargin{:});
			obj.modelFilename = 'mixedHyperboloid';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end
    end
    
    methods (Access = protected)
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
        
	end

end
