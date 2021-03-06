classdef DF_HyperbolicMagnitudeEffect < DF2
	%HyperbolicMagnitudeEffect The classic 1-parameter discount function, but
	% where log discount rate is a linear function of reward magnitude.


	properties
	end

	methods (Access = public)

		function obj = DF_HyperbolicMagnitudeEffect(varargin)
			obj = obj@DF2(varargin{:});
		end


		% TODO: refactor this. Separate getting and plotting
		function logk = getLogDiscountRate(obj, reward, index, varargin)
			% for models with magnitude effect, we might want to ask for
			% what the log(k) values are for given reward values
			p = inputParser;
			p.FunctionName = mfilename;
			p.addRequired('reward', @isnumeric);
			p.addRequired('index', @isscalar);
			p.addParameter('plot','true',@islogical)
			p.addParameter('plot_mode','row',...
				@(x)any(strcmp(x,{'row','compact','conditional_only'})))
			p.parse(reward, index, varargin{:});


			% Create an array of Stochastic objects to pass back
			for n=1:numel(reward)
				logk(n) = Stochastic('logk');
				logk_samples = obj.eval(reward(n));
				
				logk(n).addSamples(logk_samples);
			end

			% Plot logic
			if p.Results.plot
				% create a vector of subplot handles
				switch p.Results.plot_mode
					case{'row'}
						figure
						latex_fig(16, 15, 4)
						N = numel(reward) + 1;
						subplot_handles = create_subplots(N, 'row');
						plot_mag_effect(subplot_handles(1))
						obj.plot_conditional_logk(subplot_handles([2:end]), logk, p.Results.plot_mode);

					case{'compact'}
						figure
						latex_fig(16, 8,4)
						N = 2;
						subplot_handles = create_subplots(N, 'row');
						subplot_handles([2:numel(reward)+1]) = subplot_handles(2);

						plot_mag_effect(subplot_handles(1))
						obj.plot_conditional_logk(subplot_handles([2:end]), logk, p.Results.plot_mode);

					case{'conditional_only'}
						% plot in current axis
						subplot_handles = [];
						for n=1:numel(reward)
							subplot_handles = [subplot_handles gca];
						end
						obj.plot_conditional_logk(subplot_handles, logk, p.Results.plot_mode);
				end
			end
		end

		function plot_mag_effect(subplot_handle)
			% PLOT MAGNITUDE EFFECT -----------------------------------
			subplot(subplot_handle)
			% TODO: once DF_HyperbolicMagnitudeEffect owns a
			% MagnitudeEffectFunction object, then we can call it
			% directly?
			samples = obj.coda.getSamplesAtIndex_asStruct(index,{'m','c'});
			me = MagnitudeEffectFunction('samples',samples);
			me.plot()
		end

	end




	methods (Access = protected)

		function formatAxes(obj, pow)
			box off
			view([-45, 34])
			axis vis3d
			axis tight
			axis square
			zlim([0 1])
			set(gca,'YDir','reverse')
			set(gca,'XScale','log')
			set(gca,'XTick',logspace(1,pow,pow-1+1))

			xlabel('$|reward|$', 'interpreter','latex')
			ylabel('delay $D^B$', 'interpreter','latex')
			zlabel('discount factor', 'interpreter','latex')
		end

	end


	methods (Static)

		function plot_conditional_logk(subplot_handles, logk, plot_mode)
			hold on
			for n = 1:numel(logk)
				subplot(subplot_handles(n));
				logk(n).plot();
				switch plot_mode
					case{'row'}
						title( sprintf('P(log(k) | reward = %d)',reward(n)) ); % TODO: fix equation... it's not showing properly
				end
			end
		end

	end

	methods (Static, Access = protected)

		function logk = function_evaluation(x, theta)
			if verLessThan('matlab','9.1')
				logk = bsxfun(@plus, bsxfun(@times, theta.m, log(x)) , theta.c);
			else
				% use new array broadcasting in 2016b
				logk = theta.m * log(x) + theta.c;
			end
		end

	end

end
