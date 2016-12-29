classdef (Abstract) Parametric < Model
	
	properties (Access = private)
		
	end
	
	methods (Access = public)
		
		function obj = Parametric(data, varargin)
			obj = obj@Model(data, varargin{:});
		end
		
		
		function plot(obj, varargin)
			
			p = inputParser;
			p.FunctionName = mfilename;
			p.addParameter('shouldExportPlots', true, @islogical);
			p.parse(varargin{:});
			
			%% Plot functions that use data from all participants =========
			
			% #############################################################
			% #############################################################
			% TODO #166 THIS IS A LOT OF FAFF, JUST FOR UNIVARIATE SUMMARY PLOTS
			
			% gather cross-experiment data for univariate sta
			alldata.shouldExportPlots = p.Results.shouldExportPlots;
			alldata.shouldExportPlots	= obj.shouldExportPlots;
			alldata.variables			= obj.varList.participantLevel;
			alldata.filenames			= obj.data.getIDnames('all');
			alldata.savePath			= obj.savePath;
			alldata.modelFilename		= obj.modelFilename;
			alldata.plotOptions 		= obj.plotOptions;
			for v = alldata.variables
				alldata.(v{:}).hdi =...
					[obj.coda.getStats('hdi_low',v{:}),... % TODO: ERROR - expecting a vector to be returned
					obj.coda.getStats('hdi_high',v{:})]; % TODO: ERROR - expecting a vector to be returned
				alldata.(v{:}).pointEstVal =...
					obj.coda.getStats(obj.pointEstimateType, v{:});
			end
			% -------------------------------------------------------------
			% TODO: Think about plotting this with GRAMM
			% https://github.com/piermorel/gramm
			figUnivariateSummary(alldata)
			% #############################################################
			% #############################################################
			
			
			% summary figure of core discounting parameters
			clusterPlot(...
				obj.coda,...
				obj.data,...
				[1 0 0],...
				obj.modelFilename,...
				obj.plotOptions,...
				obj.varList.discountFunctionParams)
			
			
			%% Plots, one per data file ===================================
			
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			% TODO: #166 no need to package all this data up into pdata.
            % #166 TriPlot should be a plot function of CODA
            % #166 
			obj.pdata = obj.packageUpDataForPlotting();
			
			for n=1:numel(obj.pdata)
				obj.pdata(n).shouldExportPlots = p.Results.shouldExportPlots;
			end
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			
			obj.experimentPlot();
			
			% Corner plot of parameters
			arrayfun(@plotTriPlotWrapper, obj.pdata)
			
			% Posterior prediction plot
			arrayfun(@figPosteriorPrediction, obj.pdata)
		end
		
		
		function experimentPlot(obj)
			% this is a wrapper function to loop over all data files, producing multi-panel figures. This is implemented by the experimentMultiPanelFigure method, which may be overridden by subclasses if need be.
			names = obj.data.getIDnames('all');
			
			for ind = 1:numel(names)
				fh = figure('Name', names{ind});
				latex_fig(12, 14, 3)
				
				obj.experimentMultiPanelFigure(ind)
				drawnow
				
				if obj.shouldExportPlots
					myExport(obj.savePath, 'expt',...
						'prefix', names{ind},...
						'suffix', obj.modelFilename,...
						'formats', {'png'});
				end
				
				close(fh)
			end
		end
		
		function experimentMultiPanelFigure(obj, ind)
			
			h = layout([1 2 3 4]);
			opts.pointEstimateType	= obj.pointEstimateType;
			opts.timeUnits			= obj.timeUnits;
			opts.dataPlotType		= obj.dataPlotType;
			
			% create cell arrays of relevant variables
			discountFunctionVariables = {obj.varList.discountFunctionParams.name};
			responseErrorVariables    = {obj.varList.responseErrorParams.name};
			
			%% PLOT: density plot of (alpha, epsilon)
			obj.coda.plot_bivariate_distribution(h(1),...
				responseErrorVariables(1),...
				responseErrorVariables(2),...
				ind,...
				opts)
			
			%% Plot the psychometric function ----------------------------------
			subplot(h(2))
			psycho = PsychometricFunction('samples', obj.coda.getSamplesAtIndex(ind, responseErrorVariables));
			psycho.plot(obj.pointEstimateType)
			
% 			% DON'T PLOT THE SUBFIGURES BELOW IF...
% 			if isempty(dfSamples) %|| any(isnan(dfSamples))
% 				return
% 			end
			
			%% Plot the discount function parameters ---------------------------
			% TODO #166: auto deal with either 1 or 2 discount function parameters
			assert(numel(discountFunctionVariables)==1, 'Currently only able to plot univariate. Easy to make this more adaptive to 1-2 params')
			obj.coda.plot_univariate_distribution(h(3),...
				discountFunctionVariables(1),...
				ind,...
				opts)
			
			%% Plot the discount function parameters ----------------------
			subplot(h(4))
			discountFunction = obj.dfClass(...
				'samples', obj.coda.getSamplesAtIndex(ind, discountFunctionVariables),...
				'data', obj.data.getExperimentObject(ind));
			discountFunction.plot(obj.pointEstimateType,...
				obj.dataPlotType,...
				obj.timeUnits)
			% TODO #166 avoid having to parse these args in here

		end
		
	end
	
end
