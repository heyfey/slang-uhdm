class node;
  int val;
  node next;
  node prev;
  function node tail();
    node n = this;
    while (n.next != null) n = n.next;
    return n;
  endfunction
endclass
module top;
  node head;
  initial begin
    head = new;
    head.next = new;
    head.next.prev = head;
  end
endmodule
