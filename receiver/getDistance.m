function distance = getDistance(bits)

    str = num2str(bits(1:4)); % should be 8 in final version
    distance = bin2dec(str);

end