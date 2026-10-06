// § lvStreamBaseKeepsActual258 (an interface path streaming target in a module task)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; endinterface
module m(bif bit_field_if);
  task automatic t(logic [3:0] x);
    {>>{bit_field_if.read_data[3:0]}} = x;
  endtask
  initial t(4'h3);
endmodule
module top; bif b(); m u(.bit_field_if(b)); endmodule
