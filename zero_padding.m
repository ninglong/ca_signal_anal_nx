function out = zero_padding(str, len, pad_pos)

len0 = length(str);
pad = repmat('0', 1,len-len0);
if strcmpi(pad_pos, 'start')
    out = [pad str];
else strcmpi(pad_pos, 'end')
    out = [str pad];
end

    