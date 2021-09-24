function x = returnNonZero(x)
% DeepLabCut at times has issues wherein an entire length of keypoints 
% at the end of the segment are marked with 0
% This causes and issue with velocity measurement
% Return without this zero segment at the end
% But be careful regular zero
	zero_loc = find(x(2:end)==0 & (x(2:end)-x(1:end-1))==0);
	if ~isempty(zero_loc)
		x = x(1:zero_loc-1);
	end
end