// § modNettypeTypedef412
module top();
	function automatic real real_sum (input real driver[]);
		real_sum = 0.0;
		foreach (driver[i])
			real_sum += driver[i];
	endfunction
	nettype real real_net with real_sum;
	typedef int a_t;
endmodule
