function plotDiscountFunction(logKsamples, varargin)

% TODO clean up this function

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('logKsamples',@isvector);
p.addParameter('xScale','linear',@(x)any(strcmp(x,{'linear','log'})));
p.addParameter('data',[],@isstruct);
p.addParameter('pointEstimateType','mean',@isstr);
p.parse(logKsamples, varargin{:});

%% Calculate half-life
logkDistribution = mcmc.UnivariateDistribution(logKsamples,...
	'shouldPlot',false,...
	'pointEstimateType',p.Results.pointEstimateType);
logKpointEstimate = logkDistribution.(p.Results.pointEstimateType);
k = exp(logKpointEstimate);
halfLife = 1/k;
	
%% determine x-range
if ~isempty(p.Results.data)
	maxDelay = max( p.Results.data.DB );
else
	maxDelay = halfLife*100;
end


% TODO: This should be an indepedent function, the name of which is
% provided as an input
discountFraction = @(k,D) bsxfun(@rdivide, 1, 1 + (bsxfun(@times, k, D) ) );

switch p.Results.xScale
	case{'linear'}
		D = linspace(0, maxDelay, 1000);
		
		mcmc.PosteriorPrediction1D(discountFraction,...
			'xInterp',D,...
			'samples',exp(p.Results.logKsamples),...
			'ciType','examples',...
			'variableNames', {'delay', 'discount factor'},...
			'pointEstimateType',p.Results.pointEstimateType);
		
	case{'log'}
		error('')
		D = logspace(-2,4,10000);
		AB		= discountFraction(k,D);
		semilogx(D, AB);
end

% formatting
axis tight
% axis square
% box off
% xlabel('delay', 'interpreter','latex')
% ylabel('discount factor', 'interpreter','latex')
ylim([0 1])

% default scale the x axis from 0 to a multiple of the half life
xlim([0 halfLife*5])


% if we have data
if ~isempty(p.Results.data)
	hold on
	opts.maxlogB	= max( abs(p.Results.data.B) );
	opts.maxD		= max( p.Results.data.DB );

	% find unique experimental designs
	D=[abs(p.Results.data.A), abs(p.Results.data.B), p.Results.data.DA, p.Results.data.DB];
	[C, ia, ic] = unique(D,'rows');
	%loop over unique designs (ic)
	for n=1:max(ic)
		% binary set of which trials this design was used on
		myset=ic==n;
		% Size = number of times this design has been run
		F(n) = sum(myset);
		% Colour = proportion of times that participant chose immediate
		% for that design
		COL(n) = sum(p.Results.data.R(myset)==0) ./ F(n);

		%x(n) = abs(p.Results.data.B( ia(n) )); % �B
		x(n) = p.Results.data.DB( ia(n) ); % delay to get �B
		y(n) = abs(p.Results.data.A( ia(n) )) ./ abs(p.Results.data.B( ia(n) ));
	end

	% plot
	for i=1:max(ic)
		h = plot(x(i), y(i),'o');
		h.Color='k';
		h.MarkerFaceColor=[1 1 1] .* (1-COL(i));
		h.MarkerSize = F(i)+4;
		hold on
	end

	xlabel('delay, $D^B$', 'interpreter','Latex')
	%ylabel('$|A|/|B|$', 'interpreter','Latex')

	xlim([0 opts.maxD*1.1])
	ylim([0 1])
	box off

end

return
