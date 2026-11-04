// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    function automatic T f(input T a = 0);
      return a;
    endfunction
    task t();
      fork
        begin
          T l;
          l = f();
        end
      join
    endtask
  endclass
endpackage
module top; endmodule
