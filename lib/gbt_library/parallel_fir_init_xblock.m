%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://casper.berkeley.edu                                                %      
%   Copyright (C) 2011 Mark Wagner, Hong Chen                                 %
%                                                                             %
%   This program is free software; you can redistribute it and/or modify      %
%   it under the terms of the GNU General Public License as published by      %
%   the Free Software Foundation; either version 2 of the License, or         %
%   (at your option) any later version.                                       %
%                                                                             %
%   This program is distributed in the hope that it will be useful,           %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of            %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             %
%   GNU General Public License for more details.                              %
%                                                                             %
%   You should have received a copy of the GNU General Public License along   %
%   with this program; if not, write to the Free Software Foundation, Inc.,   %
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parallel_fir_init_xblock(blk, filter_coeffs)

f0=filter_coeffs(1:2:end);
f1=filter_coeffs(2:2:end);

f0pf1=f0+f1;

% validate coefficients
check = parallel_fir_coefficient_check(filter_coeffs);
if check
    return;
end


%% inports
xlsub3_In1 = xInport('In1');
xlsub3_In2 = xInport('In2');
xlsub3_In3 = xInport('In3');

%% outports
xlsub3_sync_out = xOutport('sync_out');
xlsub3_y0r = xOutport('y0r');
xlsub3_y0i = xOutport('y0i');
xlsub3_y1r = xOutport('y1r');
xlsub3_y1i = xOutport('y1i');

%% diagram

% block: half_band_xblock/Subsystem/parallel_fir/AddSub1
xlsub3_c_to_ri1_out1 = xSignal;
xlsub3_c_to_ri2_out1 = xSignal;
xlsub3_AddSub1_out1 = xSignal;
xlsub3_AddSub1 = xBlock(struct('source', 'AddSub', 'name', 'AddSub1'), ...
                        struct('mode', 'Subtraction'), ...
                        {xlsub3_c_to_ri1_out1, xlsub3_c_to_ri2_out1}, ...
                        {xlsub3_AddSub1_out1});

% block: half_band_xblock/Subsystem/parallel_fir/AddSub2
xlsub3_c_to_ri_out1 = xSignal;
xlsub3_Delay_out1 = xSignal;
xlsub3_AddSub2 = xBlock(struct('source', 'AddSub', 'name', 'AddSub2'), ...
                        [], ...
                        {xlsub3_c_to_ri_out1, xlsub3_Delay_out1}, ...
                        {xlsub3_y0r});

% block: half_band_xblock/Subsystem/parallel_fir/AddSub3
xlsub3_c_to_ri1_out2 = xSignal;
xlsub3_c_to_ri2_out2 = xSignal;
xlsub3_AddSub3_out1 = xSignal;
xlsub3_AddSub3 = xBlock(struct('source', 'AddSub', 'name', 'AddSub3'), ...
                        struct('mode', 'Subtraction'), ...
                        {xlsub3_c_to_ri1_out2, xlsub3_c_to_ri2_out2}, ...
                        {xlsub3_AddSub3_out1});

% block: half_band_xblock/Subsystem/parallel_fir/AddSub4
xlsub3_c_to_ri_out2 = xSignal;
xlsub3_Delay1_out1 = xSignal;
xlsub3_AddSub4 = xBlock(struct('source', 'AddSub', 'name', 'AddSub4'), ...
                        [], ...
                        {xlsub3_c_to_ri_out2, xlsub3_Delay1_out1}, ...
                        {xlsub3_y0i});

% block: half_band_xblock/Subsystem/parallel_fir/AddSub5
xlsub3_AddSub5 = xBlock(struct('source', 'AddSub', 'name', 'AddSub5'), ...
                        struct('mode', 'Subtraction'), ...
                        {xlsub3_c_to_ri_out1, xlsub3_AddSub1_out1}, ...
                        {xlsub3_y1r});

% block: half_band_xblock/Subsystem/parallel_fir/AddSub6
xlsub3_AddSub6 = xBlock(struct('source', 'AddSub', 'name', 'AddSub6'), ...
                        struct('mode', 'Subtraction'), ...
                        {xlsub3_c_to_ri_out2, xlsub3_AddSub3_out1}, ...
                        {xlsub3_y1i});

% block: half_band_xblock/Subsystem/parallel_fir/Delay
xlsub3_Delay = xBlock(struct('source', 'Delay', 'name', 'Delay'), ...
                      [], ...
                      {xlsub3_c_to_ri2_out1}, ...
                      {xlsub3_Delay_out1});

% block: half_band_xblock/Subsystem/parallel_fir/Delay1
xlsub3_Delay1 = xBlock(struct('source', 'Delay', 'name', 'Delay1'), ...
                       [], ...
                       {xlsub3_c_to_ri2_out2}, ...
                       {xlsub3_Delay1_out1});

% block: half_band_xblock/Subsystem/parallel_fir/c_to_ri
xlsub3_f0_out2 = xSignal;
xlsub3_c_to_ri_sub = xBlock(struct('source', str2func('c_to_ri_init_xblock'), 'name', 'c_to_ri'), ...
                        {[blk,'/c_to_ri'], 8, 7}, ...
                        {xlsub3_f0_out2}, ...
                        {xlsub3_c_to_ri_out1, xlsub3_c_to_ri_out2});

% block: half_band_xblock/Subsystem/parallel_fir/c_to_ri1
xlsub3_f0pf1_out2 = xSignal;
xlsub3_c_to_ri1_sub = xBlock(struct('source', str2func('c_to_ri_init_xblock'), 'name', 'c_to_ri1'), ...
                         {[blk,'/c_to_ri1'], 8, 7}, ...
                         {xlsub3_f0pf1_out2}, ...
                         {xlsub3_c_to_ri1_out1, xlsub3_c_to_ri1_out2});

% block: half_band_xblock/Subsystem/parallel_fir/c_to_ri2
xlsub3_f1_out2 = xSignal;
xlsub3_c_to_ri2_sub = xBlock(struct('source', str2func('c_to_ri_init_xblock'), 'name', 'c_to_ri2'), ...
                         {[blk,'/c_to_ri2'], 8, 7}, ...
                         {xlsub3_f1_out2}, ...
                         {xlsub3_c_to_ri2_out1, xlsub3_c_to_ri2_out2});

% block: half_band_xblock/Subsystem/parallel_fir/f0
xlsub3_f0_sub = xBlock(struct('source', str2func('dec_fir_init_xblock'), 'name', 'f0'), ...
                   {[blk,'/f0'], 1, f0, 4, 'Truncate', 1, 2, 25, 24, 'on'}, ...
                   {xlsub3_In1, xlsub3_In2, xlsub3_In3}, ...
                   {xlsub3_sync_out, xlsub3_f0_out2});

% block: half_band_xblock/Subsystem/parallel_fir/f0pf1
xlsub3_f0pf1_sub = xBlock(struct('source', str2func('dec_fir_init_xblock'), 'name', 'f0pf1'), ...
                      {[blk,'/f0pf1'], 1, f0pf1, 4, 'Truncate', 1, 2, 25, 24, 'on'}, ...
                      {xlsub3_In1, xlsub3_In2, xlsub3_In3}, ...
                      {[], xlsub3_f0pf1_out2});

% block: half_band_xblock/Subsystem/parallel_fir/f1
xlsub3_f1_sub = xBlock(struct('source', str2func('dec_fir_init_xblock'), 'name', 'f1'), ...
                   {[blk,'/f1'], 1, f1, 4, 'Truncate', 1, 2, 25, 24, 'on'}, ...
                   {xlsub3_In1, xlsub3_In2, xlsub3_In3}, ...
                   {[], xlsub3_f1_out2});


if ~isempty(blk) && ~strcmp(blk(1),'/')
    clean_blocks(blk);
end

end

