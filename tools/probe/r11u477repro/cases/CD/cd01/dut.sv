// § parenCallWrittenArgs477
class obj;
  function bit compare(obj rhs, obj c = null);
    return 1;
  endfunction
endclass
class packet extends obj;
endclass
class comp #(type T = packet);
  T exp;
  function void write(T rec);
    if (!(exp.compare(rec))) $display("x");
  endfunction
endclass
module top;
endmodule
