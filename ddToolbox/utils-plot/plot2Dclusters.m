function plot2Dclusters(mcmcContainer, data, col, modelType, plotOptions, varInfo)

% TODO:
% remove input:
% - mcmcContainer, just pass in the data
% - data, just pass in 
% rename to plotBivariateDistributions


% plot posteriors over (m,c) for all participants, as contour plots

probMass = 0.5;

figure(12), clf

% build samples
for p = 1:data.getNExperimentFiles()
	tempx = mcmcContainer.getSamplesAtIndex_asMatrix(p, {varInfo(1).name});
	tempy = mcmcContainer.getSamplesAtIndex_asMatrix(p, {varInfo(2).name});
	if ~isempty(tempx) && ~isempty(tempy)
		x(:,p) = tempx;
		y(:,p) = tempy;
	end
end

%% plot all actual participants
mcBivariateParticipants = mcmc.BivariateDistribution(...
	x(:,[1:data.getNRealExperimentFiles()]),...
	y(:,[1:data.getNRealExperimentFiles()]),...
	'xLabel', varInfo(1).label,...
	'yLabel', varInfo(2).label,...
	'plotStyle','contour',...
	'probMass',probMass,...
	'pointEstimateType','mode',...
	'patchProperties',definePlotOptions4Participant(col));

% TODO: enable this functionality in BivariateDistribution
% % plot numbers
% for p = 1:data.getNExperimentFiles()
% 	text(mcBivariate.mode(1),mcBivariate.mode(2),...
% 		sprintf('%d',p),...
% 		'HorizontalAlignment','center',...
% 		'VerticalAlignment','middle',...
% 		'FontSize',9,...
% 		'Color',col)
% end

% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;

%% plot unobserved participant (ie group level) if they exist
if size(x,2)==data.getNExperimentFiles() && size(y,2)==data.getNExperimentFiles()
	
	x_group = x(:,data.getNExperimentFiles());
	y_group = y(:,data.getNExperimentFiles());
	
	if ~any(isnan(x(:,end))) && ~any(isnan(x_group)) && ~any(isnan(y_group))% do we have (m,c) samples for the group-level?
		if data.isUnobservedPartipantPresent()
			mcBivariateGroup = mcmc.BivariateDistribution(...
				x_group,...
				y_group,... %xLabel',variableNames{1},'yLabel',variableNames{2},...
				'plotStyle','contour',...
				'probMass',probMass,...
				'pointEstimateType', plotOptions.pointEstimateType,...
				'patchProperties', definePlotOptions4Group(col));
		end
	end
end

axis(participantAxisBounds)
set(gca,'XAxisLocation','origin',...
	'YAxisLocation','origin')
drawnow

if plotOptions.shouldExportPlots
	myExport(plotOptions.savePath, 'summary_plot',...
		'suffix', modelType,...
        'formats', {'png'})
end

	function plotOpts = definePlotOptions4Participant(col)
		plotOpts = {'FaceAlpha', 0.1,...
			'FaceColor', col,...
			'LineStyle', 'none'};
	end

	function plotOpts = definePlotOptions4Group(col)
		plotOpts = {'FaceColor', 'none',...
			'EdgeColor', col,...
			'LineWidth', 2};
	end
end