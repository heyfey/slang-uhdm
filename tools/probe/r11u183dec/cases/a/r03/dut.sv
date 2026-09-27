package p;
class eb; endclass
class msg;
  typedef eb queue_of_element[$];
  local queue_of_element _elements;
  virtual function queue_of_element get_elements();
    return _elements;
  endfunction
endclass
endpackage
module top; endmodule
