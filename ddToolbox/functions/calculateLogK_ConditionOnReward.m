function [posteriorMean,lh] = calculateLogK_ConditionOnReward(reward, params, plotFlag)
	lh=[];
	% -----------------------------------------------------------
	% log(k) = m * log(B) + c
	% k = exp( m * log(B) + c )
	%fh = @(x,params) exp( params(:,1) * log(x) + params(:,2));
	% a FAST vectorised version of above ------------------------
	fh = @(x,params) exp( bsxfun(@plus, ...
		bsxfun(@times,params(:,1),log(x)),...
		params(:,2)));
	% -----------------------------------------------------------

	myplot = mcmc.PosteriorPrediction1D(fh,...
		'xInterp',reward,...
		'samples',params);
	myplot = myplot.evaluateFunction([]);

	% Extract samples of P(k|reward)
	kSamples = myplot.Y;
	logKsamples = log(kSamples);

	% Calculate kernel density estimate
	[f,xi] = ksdensity(logKsamples, 'function', 'pdf');

	%posteriorMode = xi( argmax(f) );
	posteriorMean = mean(logKsamples);

	if plotFlag
		figure(1)
		lh = plot(xi,f);
		hold on
		drawnow
	end

end