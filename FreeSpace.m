function y = FreeSpace(SampleRate,OperatingFrequency,x,endPos)
    % The freespace signal calculation takes into concideration that the signal
    % is propogating two ways

    numOfPropPaths = size(x,2);  

    % Calculate Propogated Signal and the Delay
    [temp_output_signal,propdelay] = calculatePropagatedSignalOutput(x,numOfPropPaths,endPos,OperatingFrequency);
    nDelay = propdelay*SampleRate;

    % Check to see if delay can be divided by the sample rate with no remainder
    % -> If this is true the delayed signal output does not need to be
    % calculated for this channel
    isDelayIntSamples = (rem(propdelay,1/SampleRate) == 0);
    % For exact samples, round nDelay in case numerical error
    % exists
    nDelay(isDelayIntSamples) = round(nDelay(isDelayIntSamples));
    tempDelay = nDelay;
    tempDelay(isDelayIntSamples) = 0;

    % Computes the fractional delay that cannot be expresses as an integer
    % shift in the freespace array
    FDF = dsp.VariableFractionalDelay;
    integer_delay = floor(tempDelay);
    fractional_delay = tempDelay-integer_delay; 
    temp_output_signal = step(FDF,temp_output_signal,fractional_delay);

    % Shift the signal from the start of the frame through the freespace 
    % proportionally to the distance that it is away as an integer now 

    move_to = floor(nDelay);

    % Typically a circle buffer would be used here so that when a number of
    % pulses are being integrated and there is an object far enough to overflow
    % the pulse repetition frequency the signal from the current freespace
    % output will bleed into the next 
    % In this case we assume that there is no overflow and everything is just
    % shifted and the previous signal bleeding in is not taken into account

    for m = 1:size(move_to,2)
        y_out(:,m) = circshift(temp_output_signal(:,m),move_to(1,m),1);
    end

    y = y_out;
    
function [y,propagation_delay] = calculatePropagatedSignalOutput(x,numOfPropPaths,location,OperatingFrequency)
    % Add propagation loss and phase change
    propagation_speed = physconst('LightSpeed');
    y = complex(zeros(size(x)));
    lambda = propagation_speed/OperatingFrequency;
    
    % propagation distance
    propagation_distance = location(1,:);  
    propagation_delay = 2*propagation_distance/propagation_speed;
   
    free_space_path_loss = 4*pi*propagation_distance(:)*(1./lambda(:).');
    free_space_path_loss = mag2db(free_space_path_loss);
    loss = 2*free_space_path_loss;
    
    loss_factor = sqrt(db2pow(loss));
    for colum_index = 1:numOfPropPaths
        y(:,colum_index) = exp(-1i*2*pi*2*propagation_distance(colum_index)/lambda)/loss_factor(colum_index)*x(:,colum_index);                  
    end





