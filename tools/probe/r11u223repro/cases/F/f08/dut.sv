// § tfArgScalarTdWriter223
typedef int UVM_FILE;
module top;
  function automatic int set(UVM_FILE file);
    return file;
  endfunction
  UVM_FILE f;
  initial f = set(3);
endmodule
