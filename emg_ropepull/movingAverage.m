function emg_moving_average = movingAverage(emg_signal, window_duration, sampling_frequency,dim)
% emg_moving_average = movingAverage(emg_signal, window_duration, sampling_frequency);
% A moving-average filter is a common method used for smoothing noisy data. This example uses the filter function to compute averages along a vector of data.
% Create a 1-by-100 row vector of sinusoidal data that is corrupted by random noise.
% t = linspace(-pi,pi,100);
% rng default  %initialize random number generator
% x = sin(t) + 0.25*rand(size(t));
% A moving-average filter slides a window of length  $windowSize$ along the data, computing averages of the data contained in each window. The following difference equation defines a moving-average filter of a vector  $x$:
% $$ y(n)=\frac{1}{windowSize}\left(x(n)+x(n-1)+...+x(n-(windowSize-1))\right). $$
% For a window size of 5, compute the numerator and denominator coefficients for the rational transfer function.
% windowSize = 5;
% b = (1/windowSize)*ones(1,windowSize);
% a = 1;
% Find the moving average of the data and plot it against the original data.
% y = filter(b,a,x);
% plot(t,x)
% hold on
% plot(t,y)
% legend('Input Data','Filtered Data')
windowSize = round(window_duration*sampling_frequency);
b = (1/windowSize)*ones(1,windowSize);
a = 1;
if nargin<4
  emg_moving_average = filter(b, a, emg_signal);
else
  emg_moving_average = filter(b, a, emg_signal,[],dim);
end