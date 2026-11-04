// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    task t();
      begin
        CB cb;
      end
    endtask
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
