function figPosteriorPrediction(data)
% figPosteriorPrediction  Takes output from posterior predictive analysis
% and plots to a multi-panelled figure.
%   figPosteriorPrediction(data)

% skip if there are no trials (eg if we are dealing with group-level
% inferences)
if isempty(data.data.trialsForThisParticant)
	return
end

% MAIN FUNCTION TO PRODUCE MUTLI-PANEL FIGURE

figure(1), colormap(gray), clf

h = layout([1 1; 2 3]);

latex_fig(16, 9, 6)

subplot(h(1))
pp_plotTrials()

subplot(h(2))
pp_plotGOFdistribution()

% subplot(2,2,3)
% pp_plotPredictionAndResponse()

subplot(h(3))
pp_plotPercentPredictedDistribution()

% Export figure
drawnow
if data.shouldExportPlots
	myExport(data.plotOptions.savePath, 'PosteriorPredictive',...
		'prefix', data.IDname{:},...
		'suffix', data.modelFilename,...
		'formats', data.plotOptions.exportFormats)
end

	function pp_plotGOFdistribution()
		uni = mcmc.UnivariateDistribution(data.postPred.GOF_distribtion(:),...
			'xLabel', 'goodness of fit score',...
			'plotStyle','hist',...
			'pointEstimateType',data.pointEstimateType);
	end

	function pp_plotPercentPredictedDistribution()
		uni = mcmc.UnivariateDistribution(data.postPred.percentPredictedDistribution(:),...
			'xLabel', '$\%$ proportion responses accounted for',...
			'plotStyle','hist',...
			'pointEstimateType',data.pointEstimateType);
		
		axis tight
		vline(0.5);
		set(gca,'XLim',[0 1])
	end

	function pp_plotTrials()
		% plot predicted probability of choosing delayed
		bar(data.postPred.responses_predicted,'BarWidth',1)
		
		box off
		axis tight
		% plot response data
		hold on
		plot([1:data.data.trialsForThisParticant], data.postPred.responses_actual, '+')
		%title(data.titleString)
		
		xlabel('trial')
		ylabel('response')
		legend('prediction','response', 'Location','East')
	end

	function pp_plotPredictionAndResponse()
		hz(1) = plot(data.postPred.responses_predicted, data.postPred.responses_actual, '+');
		xlabel('Predicted P(choose delayed)')
		ylabel('Actual response')
		legend(hz, 'data')
		box off
	end

end
