% Simulation of OFDM transmitter and receiver with 
% sub-carriers = 64, 
% cyclic prefix = 6, 
% channel length = 3 
% for BPSK as the modulation technique

%%
clc;
clear;
close all;

N = 64; % number of subcarriers
CP = 6; % number of cyclic prefix
L = 3; % channel length
SNR_dB_range = -5:5:55; % SNR in dB
no_of_block = 1e4; % number of block
mean_sq=1; % mean square value
pow=1; % power of bpsk signal
BER=[]; % empty array

for SNR_dB = SNR_dB_range
    SNR=10^(SNR_dB/10);
    var=mean_sq*pow/SNR;
    for i = 1:no_of_block
        input = randi([0,1],1,N);
        BPSK=2*input-1;

        S = ifft(BPSK); % applying IFFT
        S_CP = [S(1,N-CP+1:end),S]; % adding cyclic prefix

        h = sqrt(1/2)*(randn(1,L)+sqrt(-1)*randn(1,L)); % channel coefficient
        n = sqrt(var/2)*(randn(1,N+CP)+sqrt(-1)*randn(1,N+CP)); % complex noise

        R_CP = cconv(S_CP,h,N+CP)+n; % received signal with cyclic prefix
        R = R_CP(1,CP+1:end); % recovery of bits from from received

        received_symbol = fft(R); % receieved signal after removing cyclic prefix
        fft_chan = fft(h,N); % fft of channel

        estimated_symbol = received_symbol./fft_chan; % recovery of estimated signal

        % Estimation
        estimated_bits(estimated_symbol>0) = 1;
        estimated_bits(estimated_symbol<0) = 0;

        % BER calculation per block
        BER_per_block(i)=(N-sum(input==estimated_bits))/N;
    end

    % BER calculation
    no_of_error = sum(BER_per_block);
    cal_BER = no_of_error/no_of_block;
    BER = [BER cal_BER];
end

% plot BER vs SNR
semilogy(SNR_dB_range,BER,'bo-','Linewidth',1.5);
title('BER of OFDM');
xlabel('SNR_d_B');
ylabel('BER');
legend('BER BPSK in OFDM')
grid on

%%
