function plotPeakDistHistogram(animal, peak_dist, seg, bins,plotStyle)
% Comparison Histogram Plots
% peak dist is a cell array of peak dist values
channels = {'bi','tri','trap','ecu'};
segments = {'discrete', 'rhythmic'};
seg_index = find(strcmpi(segments, seg));
figure;hold on;
for j = 1:length(channels)
	hcount = [];
	for k = 1:length(peak_dist)
		if nargin==3
			subplot(length(channels), length(peak_dist), (j-1)*2+k)
			histogram(peak_dist{k}{j,seg_index})
			title(channels{j})
		elseif nargin==4
			subplot(length(channels), length(peak_dist), (j-1)*2+k)
			histogram(peak_dist{k}{j,seg_index}, bins)
			title(channels{j})
		elseif nargin==5
			if strcmpi(plotStyle, 'overlay')
				hcount(:, k) = histcounts(peak_dist{k}{j,seg_index},bins);
			else
				subplot(length(channels), length(peak_dist), (j-1)*2+k)
				histogram(peak_dist{k}{j,seg_index})
				title(channels{j})
			end
		end
		
	end
	if nargin==5 & (strcmpi(plotStyle, 'overlay')) & (length(hcount)>0)
        subplot(length(channels), 1, j)
		bar(bins(1:end-1), hcount')
		title(channels{j})
	end

end
hold off;
saveas(gcf,[animal, '_histogram.png']);
