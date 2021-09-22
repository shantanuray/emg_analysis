function kmProcessed = kinematicsProcessor(kmData, keypoints, fps, varargin)
	kmProcessed = kmData;
	p = readInput(varargin);
	[segments] = parseInput(p.Results);
	for kp = 1:length(keypoints)
		if ~(isempty(kmProcessed.(keypoints{kp}).x)|isempty(kmProcessed.(keypoints{kp}).y))
			kmProcessed.(keypoints{kp}).relDist = eucDist(kmProcessed.(keypoints{kp}).x, kmProcessed.(keypoints{kp}).y);
			kmProcessed.(keypoints{kp}).relVelocity = kmProcessed.(keypoints{kp}).relDist*fps;
			kmProcessed.(keypoints{kp}).relXVelocity = eucDist(kmProcessed.(keypoints{kp}).x)*fps;
			kmProcessed.(keypoints{kp}).relYVelocity = eucDist(kmProcessed.(keypoints{kp}).y)*fps;
			for seg = 1:length(segments)
				if ~(isempty(kmProcessed.(keypoints{kp}).(segments{seg}).x)|isempty(kmProcessed.(keypoints{kp}).(segments{seg}).y))
					kmProcessed.(keypoints{kp}).(segments{seg}).relDist = eucDist(kmProcessed.(keypoints{kp}).(segments{seg}).x, ...
																			 kmProcessed.(keypoints{kp}).(segments{seg}).y);
					kmProcessed.(keypoints{kp}).(segments{seg}).relVelocity = kmProcessed.(keypoints{kp}).(segments{seg}).relDist*fps;
					kmProcessed.(keypoints{kp}).(segments{seg}).relXVelocity = eucDist(kmProcessed.(keypoints{kp}).(segments{seg}).x)*fps;
					kmProcessed.(keypoints{kp}).(segments{seg}).relYVelocity = eucDist(kmProcessed.(keypoints{kp}).(segments{seg}).y)*fps;
				else
					kmProcessed.(keypoints{kp}).(segments{seg}).relDist = [];
					kmProcessed.(keypoints{kp}).(segments{seg}).relVelocity = [];
					kmProcessed.(keypoints{kp}).(segments{seg}).relXVelocity = [];
					kmProcessed.(keypoints{kp}).(segments{seg}).relYVelocity = [];
				end
			end
		else
			kmProcessed.(keypoints{kp}).relDist = [];
			kmProcessed.(keypoints{kp}).relVelocity = [];
			kmProcessed.(keypoints{kp}).relXVelocity = [];
			kmProcessed.(keypoints{kp}).relYVelocity = [];
			for seg = 1:length(segments)
				kmProcessed.(keypoints{kp}).(segments{seg}).relDist = [];
				kmProcessed.(keypoints{kp}).(segments{seg}).relVelocity = [];
				kmProcessed.(keypoints{kp}).(segments{seg}).relXVelocity = [];
				kmProcessed.(keypoints{kp}).(segments{seg}).relYVelocity = [];
			end
		end
	end

	%% Read input
    function p = readInput(input)
        %   - segments 				Default - {'discrete', 'rhythmic'}
        p = inputParser;
        segments = {'discrete', 'rhythmic'};
        addParameter(p,'segments',segments, @iscell);
        parse(p, input{:});
    end

    function [segments] = parseInput(p)
        segments = p.segments;
    end
end