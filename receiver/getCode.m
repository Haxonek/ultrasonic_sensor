function code = getCode(bits)

    str = num2str(bits(1:5));
    code = bin2dec(str);

end