function [foundPreambleAndHeader] = findMessageV1(pbits)

    foundPreambleAndHeader = true;

    preamble = [1 0 1];
    header = [0 0 1];
    ph = [preamble, header];

    if length(pbits) < 3
        disp('Bit length is too short to be preamble');
        foundPreambleAndHeader = false;
        return;
    end

    for i = 1:length(ph)
%         fprintf('%d ~= %d\n', ph(i), pbits(i))
        if (ph(i) ~= pbits(i))
            foundPreambleAndHeader = false;
            return;
        end
    end

end