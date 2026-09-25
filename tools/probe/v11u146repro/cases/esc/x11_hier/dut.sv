// § escIdPpColumnShift146
module sub(input i, output \o$ ); assign \o$  = i; endmodule
module top(input a, output y, output z);
  sub u(.i(a), .\o$ (y)); assign z = u.\o$  & a;
endmodule
