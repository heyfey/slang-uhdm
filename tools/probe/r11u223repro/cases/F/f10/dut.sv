// § tfArgScalarTdWriter223
module top;
  typedef int file_t;
  typedef bit [3:0] nib_t;
  function automatic int set(file_t file, nib_t n);
    return file + n;
  endfunction
  file_t f;
  initial f = set(3, 4'h1);
endmodule
