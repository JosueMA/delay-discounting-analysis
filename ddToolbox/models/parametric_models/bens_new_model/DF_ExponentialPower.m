classdef DF_ExponentialPower < DiscountFunction
	%DF_ExponentialPower The classic 1-parameter discount function

	properties (Dependent)
		
	end
	
	methods (Access = public)

		function obj = DF_ExponentialPower(varargin)
			obj = obj@DiscountFunction(varargin{:});
			
			obj.theta.k = Stochastic('k');
            obj.theta.tau = Stochastic('tau');
            
            obj = obj.parse_for_samples_and_data(varargin{:});
		end
        
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				error('implement this using bsxfun: y = exp( - theta.k .* x.^theta.tau )')
			else
				% use new array broadcasting in 2016b
				y = exp( - theta.k .* x.^theta.tau );
			end
		end
		
	end

end
