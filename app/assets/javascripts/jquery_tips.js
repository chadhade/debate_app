// For  Minimize Icon
$(".waiting-icon").qtip({
   	content: 'Minimize Debate and Receive Updates.',
   	position: {
      corner: {
         target: 'topMiddle',
         tooltip: 'bottomMiddle'
      }
   	},
	style: { 
	 	name: 'blue',
		color: 'black',
		border: {
			width: 2,
			color: '#0000FF'
		},
		width: 275,
		tip: 'bottomMiddle'
	}
});
$("#info-footnotes").qtip({
   	content: 'Use double parenthesis like ((this)) to add footnotes to your arguments.',
   	position: {
      corner: {
         target: 'topMiddle',
         tooltip: 'bottomRight'
      }
   	},
	style: { 
	 	name: 'blue',
		color: 'black',
		border: {
			width: 2,
			color: '#0000FF'
		},
		width: 250,
		tip: 'bottomRight'
	}
});
$("#info-votes").qtip({
   	content: 'Click on the numbers below to upvote or downvote an argument.',
   	position: {
      corner: {
         target: 'topMiddle',
         tooltip: 'bottomRight'
      }
   	},
	style: { 
	 	name: 'blue',
		color: 'black',
		border: {
			width: 2,
			color: '#0000FF'
		},
		width: 250,
		tip: 'bottomRight'
	}
});
