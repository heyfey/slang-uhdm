// § parenCallWrittenArgs477
class obj;
  function bit compare(obj rhs, obj c = null);
    return 1;
  endfunction
endclass
class comp;
  obj exp;
  bit b;
  function void write(obj rec);
    if ((exp.compare(rec))) b = 1;
  endfunction
endclass
module top;
endmodule
