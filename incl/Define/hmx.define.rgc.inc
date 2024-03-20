GROUP_INFO = record
    rtvinfo : array [1..U_MAX_RTV] of RTV_INFO;
    rtvwork : array [1..U_MAX_WORK] of RTV_WORK;
    rtvmaul : array [1..U_MAX_RTV] of RTV_WORK;
    rtvmove : array [1..U_MAX_RTV] of RTV_WORK;
end;
