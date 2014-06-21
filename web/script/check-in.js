
function find_place(name, list) {

   if (!list || !list.rows || !name) {
      return -1;
   }
   // Binary search for correct place to insert the row.
   var start = 1;  // Start at 1 because the header is 0
   var end = list.rows.length;
   var mid = -1;
   var compare;
   while (start < end) {
      mid = ((end - start) / 2 >>0)+ start;
      
      compare = list.rows[mid].cells[1].innerHTML ? name.localeCompare(list.rows[mid].cells[1].innerHTML) : -1;

      if (0 === compare) {
         break;
      } else if (0 > compare) {
         end = mid;
      } else {
         start = ++mid;
      }
   }
	
	return mid;
}

function Edit(fencerid) {

	document.location = "check-in.cgi?wp=" + compid +"&Action=Edit&Item=" + fencerid;
}

function GetFencers(fencerid, action) {
	var m=document.getElementById('openModal'); 
	m.style.opacity=1; 
	m.style.pointerEvents='auto'; 
      
	//var url = 'checkin.php?wp=' + compid;
	var url = 'json.cgi?wp=' + compid;

	if (undefined != action && undefined != fencerid && '' != action && '' != fencerid) {
	url += '&action=' + action + '&id=' + fencerid;
	} else
	url += '&action=list';

   var http_request = false;
   if (window.XMLHttpRequest) { // Mozilla, Safari,...
      http_request = new XMLHttpRequest();
      if (http_request.overrideMimeType) {
         http_request.overrideMimeType('application/json');
      }
   } else if (window.ActiveXObject) { // IE
      try {
         http_request = new ActiveXObject("Msxml2.XMLHTTP");
      } catch (e) {
         try {
            http_request = new ActiveXObject("Microsoft.XMLHTTP");
         } catch (e) { }
      }
   }
   if (!http_request) {
      alert('Cannot create XMLHTTP instance');

      return false;
   }

	http_request.onreadystatechange =
	 function() {
		if (http_request.readyState == 4) {
         // Get the recent list
         var recentlist = document.getElementById('Recent');
         
		   if (http_request.status == 200 || http_request.status == 0) {

				
				// Paint the fencers.
				var jsonObj = JSON.parse(http_request.responseText);
				
				// Get the absent list
				var absentlist = document.getElementById('Absent');
			
				// Get the present list
				var presentlist = document.getElementById('Present');
				
				// Get the scratched list
				var scratchedlist = document.getElementById('Scratched');
				
				
				var len = jsonObj.absent.length;
				
            var row, checkcell, namecell, clubcell, natcell, editcell, scratchcell;
				for (var i = 0; i < len; ++i) {
					
					var fencer = jsonObj.absent[i];
					
					// Try to find the object in the checkin list by searching for the appropriate row id.
					if (null === document.getElementById('AbsRow' + fencer.id) && null != absentlist) {
						// Not found so insert it
					
						//Insert the row at the correct place
						row = absentlist.insertRow(find_place(fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom, absentlist));
						row.id = 'AbsRow' + fencer.id;
						checkcell = row.insertCell(0);
						namecell = row.insertCell(1);
						clubcell = row.insertCell(2);
						natcell = row.insertCell(3);
                  var rankcell = row.insertCell(4);
                  var memnumcell = row.insertCell(5);
                  var paidcell = row.insertCell(6);
						editcell = row.insertCell(7);
						scratchcell = row.insertCell(8);
						
						checkcell.innerHTML = '<button id="AbsChkButton' + fencer.id + '" onclick="CheckIn(\'' + fencer.id + '\', \'' + (fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom) + ' \', \''+ (fencer.club ? fencer.club : 'U/A') + '\', \'' + (fencer.nation ? fencer.nation : 'U/A') +'\')">Check-in</button>';
						namecell.innerHTML = fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom;
						clubcell.innerHTML = fencer.club ? fencer.club : 'U/A';
						natcell.innerHTML = fencer.nation ? fencer.nation : 'U/A';
                  rankcell.innerHTML = fencer.ranking ? fencer.ranking : '999';
						memnumcell.innerHTML = fencer.licence ? fencer.licence : fencer.licence_fie;
						paidcell.innerHTML = fencer.paiement ? fencer.paiement : 'Unk';
						editcell.innerHTML = '<button id="AbsEditButton' + fencer.id + '" onclick="Edit(\'' + fencer.id + '\')">Edit</button>';
						scratchcell.innerHTML = '<button id="AbsScratchButton' + fencer.id + '" onclick="Scratch(\'' + fencer.id + '\', \'' + (fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom) + ' \', \''+ (fencer.club ? fencer.club : 'U/A') + '\', \'' + (fencer.nation ? fencer.nation : 'U/A') +'\')">Scratch</button>';

						
						// Now check whether it is in the recent list and if so delete it because the fencer hasn't recently been checked in
						var recentrow = document.getElementById('RecRow' + fencer.id);
						if (null != recentrow) {
							recentlist.deleteRow(recentrow.rowIndex);
						}
					}
					// Now check whether it is in the present list and if so delete it because the fencer isn't present
					var presentrow = document.getElementById('PresRow' + fencer.id);
					if (null !== presentrow) {
						presentlist.deleteRow(presentrow.rowIndex);
					}
					// Now check whether it is in the scratched list and if so delete it because the fencer isn't present
					var scratchrow = document.getElementById('ScratRow' + fencer.id);
					if (null !== scratchrow) {
						scratchedlist.deleteRow(scratchrow.rowIndex);
					}					
				}
								
				var len = jsonObj.present.length;
				
				for (var i = 0; i < len; ++i) {
					
					var fencer = jsonObj.present[i];
					
					// Try to find the object in the present list by searching for the appropriate row id.
					if (null === document.getElementById('PresRow' + fencer.id) && null !== presentlist) {
					
						//Insert the row at the end
						row = presentlist.insertRow(find_place(fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom, presentlist));
						row.id = 'PresRow' + fencer.id;
						checkcell = row.insertCell(0);
						namecell = row.insertCell(1);
						clubcell = row.insertCell(2);
						natcell = row.insertCell(3);
						editcell = row.insertCell(4);
						scratchcell = row.insertCell(5);
						
						checkcell.innerHTML = '<button id="PresChkButton' + fencer.id + '" onclick="UndoCheckIn(\'' + fencer.id + '\')">Undo Check-in</button>';
						namecell.innerHTML = (fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom);
						clubcell.innerHTML = fencer.club;
						natcell.innerHTML = fencer.nation;
						editcell.innerHTML = '<button id="PresEditButton' + fencer.id + '" onclick="Edit(\'' + fencer.id + '\')">Edit</button>';
						
						scratchcell.innerHTML = '<button id="PresScratchButton' + fencer.id + '" onclick="Scratch(\'' + fencer.id + '\', \'' + (fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom) + ' \', \''+ (fencer.club ? fencer.club : 'U/A') + '\', \'' + (fencer.nation ? fencer.nation : 'U/A') +'\')">Scratch</button>';
					}
					
					// Now check whether it is in the checkin list and if so delete it because the fencer is present
					var absrow = document.getElementById('AbsRow' + fencer.id);
					if (null !== absrow) {
						absentlist.deleteRow(absrow.rowIndex);
					}
					// Now check whether it is in the scratched list and if so delete it because the fencer isn't present
					var scratchrow = document.getElementById('ScratRow' + fencer.id);
					if (null !== scratchrow) {
						scratchedlist.deleteRow(scratchrow.rowIndex);
					}		
					
				}
				var len = jsonObj.scratched.length;
				
				for (var i = 0; i < len; ++i) {
					
					var fencer = jsonObj.scratched[i];
					
					// Try to find the object in the present list by searching for the appropriate row id.
					if (null === document.getElementById('ScratRow' + fencer.id) && null !== scratchedlist) {
					
						//Insert the row at the end
						row = scratchedlist.insertRow(find_place(fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom, scratchedlist));
						row.id = 'ScratRow' + fencer.id;
						checkcell = row.insertCell(0);
						namecell = row.insertCell(1);
						clubcell = row.insertCell(2);
						natcell = row.insertCell(3);
						editcell = row.insertCell(4);
						scratchcell = row.insertCell(5);
						
						checkcell.innerHTML = '<button id="ScratChkButton' + fencer.id + '" onclick="CheckIn(\'' + fencer.id + '\', \'' + (fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom) + '\', \''+ (fencer.club ? fencer.club : 'U/A') + '\', \'' + (fencer.nation ? fencer.nation : 'U/A') +'\')">Check-in</button>';
						namecell.innerHTML = (fencer.name ? fencer.name : fencer.nom + ' ' + fencer.prenom);
						clubcell.innerHTML = fencer.club;
						natcell.innerHTML = fencer.nation;
						editcell.innerHTML = '<button id="PresEditButton' + fencer.id + '" onclick="Edit(\'' + fencer.id + '\')">Edit</button>';
						
						scratchcell.innerHTML = '<button id="ScratScratchButton' + fencer.id + '" onclick="UndoScratch(\'' + fencer.id + '\')">Undo Scratch</button>';
					}
					
					// Now check whether it is in the checkin list and if so delete it because the fencer is scratched
					var absrow = document.getElementById('AbsRow' + fencer.id);
					if (null !== absrow) {
						absentlist.deleteRow(absrow.rowIndex);
					}
					// Now check whether it is in the present list and if so delete it because the fencer isn't present
					var presentrow = document.getElementById('PresRow' + fencer.id);
					if (null !== presentrow) {
						presentlist.deleteRow(presentrow.rowIndex);
					}	
				}
		   } else {
				// We've had an error so remove from the recent list
				var recentrow = document.getElementById('RecRow' + fencerid);
				if (null !== recentrow) {
					recentlist.deleteRow(recentrow.rowIndex);
				}
				
				var absbutton = document.getElementById('AbsChkButton' + fencerid);
				if (null !== absbutton) {
					absbutton.disabled = false;
				}
				var presbutton = document.getElementById('PresChkButton' + fencerid);
				if (null !== presbutton) {
					presbutton.disabled = false;
				}
				var scratbutton = document.getElementById('ScratChkButton' + fencerid);
				if (null !== scratbutton) {
					scratbutton.disabled = false;
				}
				chkbutton = document.getElementById('AbsEditButton' + fencerid);
				if (null !== chkbutton) {
					chkbutton.disabled = false;
				}
				presbutton = document.getElementById('PresEditButton' + fencerid);
				if (null !== presbutton) {
					presbutton.disabled = false;
				}
				scratbutton = document.getElementById('ScratEditButton' + fencerid);
				if (null !== scratbutton) {
					scratbutton.disabled = false;
				}
				chkbutton = document.getElementById('AbsScratchButton' + fencerid);
				if (null !== chkbutton) {
					chkbutton.disabled = false;
				}
				presbutton = document.getElementById('PresScratchButton' + fencerid);
				if (null !== presbutton) {
					presbutton.disabled = false;
				}
				scratbutton = document.getElementById('ScratScratchButton' + fencerid);
				if (null !== scratbutton) {
					scratbutton.disabled = false;
				}
		   }
		   // Reset the overlay so that it isn't seen and doesn't stop the pointer events working on the main page
			m.style.opacity=0; 
			m.style.pointerEvents='none'; 
		}
	 };
	 
	http_request.open('GET', url, true);
	http_request.send(null);
}
function UndoCheckIn(id) {
	// Disable the buttons so we can't be clicked twice
	var presbutton = document.getElementById('PresChkButton' + id);
	if (null !== presbutton) {
		presbutton.disabled = true;
   }
		
	var edtbutton = document.getElementById('PresEditButton' + id);
	if (null !== edtbutton) {
		edtbutton.disabled = true;
   }
		
	var scratbutton = document.getElementById('PresScratchButton' + id);
	if (null !== scratbutton) {
		scratbutton.disabled = true;
   }
	
	// Disable the buttons so we can't be clicked twice
	var recbutton = document.getElementById('RecChkButton' + id);
	if (null !== recbutton) {
		recbutton.disabled = true;
   }
		
	edtbutton = document.getElementById('RecEditButton' + id);
	if (null !== edtbutton) {
		edtbutton.disabled = true;
   }
	scratbutton = document.getElementById('RecScratchButton' + id);
	if (null !== scratbutton) {
		scratbutton.disabled = true;
   }
		
	// Get the recent list
	var recentlist = document.getElementById('Recent');
	
	// Now check whether it is in the recent list and if so delete it because the fencer hasn't recently been checked in
	var recentrow = document.getElementById('RecRow' + id);
	
	if (null != recentrow) {
		recentlist.deleteRow(recentrow.rowIndex);
	}

	GetFencers(id, 'uncheck');
}

function CheckIn(id, name, club, nation) {
	
	// Disable the buttons so we can't be clicked twice
	var chkbutton = document.getElementById('AbsChkButton' + id);
	if (null != chkbutton) {
		chkbutton.disabled = true;
   }
		
	var edtbutton = document.getElementById('AbsEditButton' + id);
	if (null != edtbutton) {
		edtbutton.disabled = true;
   }
		
	var scratbutton = document.getElementById('AbsScratchButton' + id);
	if (null != scratbutton) {
		scratbutton.disabled = true;
   }

	// Are we already in the recent list?  Remove if we are and readd to make sure the buttons are correct
	
   var recentlist = document.getElementById('Recent');
   var recrow = document.getElementById('RecRow' + id);
	if (null !== recrow) {
      recentlist.deleteRow(recrow.rowIndex);
   } else {
		// Remove the last row if the list is longer than 10
		if (10 < recentlist.rows.length)
			recentlist.deleteRow(recentlist.rows.length -1);
	}
	
	recentlist = document.getElementById('Recent');
		
   var recrow = recentlist.insertRow(1);
   recrow.id = 'RecRow' + id;
   var buttoncell = recrow.insertCell(0);
   var namecell = recrow.insertCell(1);
   var clubcell = recrow.insertCell(2);
   var numcell = recrow.insertCell(3);
   var editcell = recrow.insertCell(4);
   var scratchcell = recrow.insertCell(5);
   
   buttoncell.innerHTML = '<button id="RecChkButton' + id + '" onclick="UndoCheckIn(\'' + id + '\')">Undo Check-in</button>';
   namecell.innerHTML = name;
   clubcell.innerHTML = club;
   numcell.innerHTML = nation;
   editcell.innerHTML = '<button id="RecEditButton' + id + '" onclick="Edit(\'' + id + '\')">Edit</button>';
   scratchcell.innerHTML = '<button id="RecScratchButton' + id + '" onclick="Scratch(\'' + id + '\', \'' + name + '\', \'' + club + '\', \'' + nation + '\')">Scratch</button>';
		
		
	GetFencers(id, 'check');
	
}


function UndoScratch(id) {
	// Disable the buttons so we can't be clicked twice
	var chkbutton = document.getElementById('ScratChkButton' + id);
	if (null !== chkbutton) 
		chkbutton.disabled = true;
		
	var edtbutton = document.getElementById('ScratEditButton' + id);
	if (null !== edtbutton) 
		edtbutton.disabled = true;
		
	var scratbutton = document.getElementById('ScratScratchButton' + id);
	if (null !== scratbutton)
		scratbutton.disabled = true;
	
	// Disable the buttons so we can't be clicked twice
	chkbutton = document.getElementById('RecChkButton' + id);
	if (null !== chkbutton) 
		chkbutton.disabled = true;
      
	edtbutton = document.getElementById('RecEditButton' + id);
	if (null !== edtbutton) 
		edtbutton.disabled = true;
		
	scratbutton = document.getElementById('RecScratchButton' + id);
	if (null !== scratbutton)
		scratbutton.disabled = true;
		
	// Get the recent list
	var recentlist = document.getElementById('Recent');
	
	// Now check whether it is in the recent list and if so delete it because the fencer hasn't recently been checked in
	var recentrow = document.getElementById('RecRow' + id);
	if (null !== recentrow) {
		recentlist.deleteRow(recentrow.rowIndex);
	}

	GetFencers(id, 'unscratch');
}
function Scratch(id, name, club, nation) {
	
	// Disable the buttons so we can't be clicked twice
	var chkbutton = document.getElementById('AbsChkButton' + id);
	if (null !== chkbutton)
		chkbutton.disabled = true;
	var edtbutton = document.getElementById('AbsEditButton' + id);
	if (null !== edtbutton)
		edtbutton.disabled = true;
		
	var scratbutton = document.getElementById('AbsScratchButton' + id);
	if (null != scratbutton) {
		scratbutton.disabled = true;
   }
	
	// Are we already in the recent list? If so then readd as we are probably either scratching or checking in from the recent list
	
   var recentlist = document.getElementById('Recent');
   var recrow = document.getElementById('RecRow' + id);
	if (null !== recrow) {
      recentlist.deleteRow(recrow.rowIndex);
   } else {
		// Remove the last row if the list is longer than 10
		if (10 < recentlist.rows.length)
			recentlist.deleteRow(recentlist.rows.length -1);
	}
	
   
   recrow = recentlist.insertRow(1);
   recrow.id = 'RecRow' + id;
   var buttoncell = recrow.insertCell(0);
   var namecell = recrow.insertCell(1);
   var clubcell = recrow.insertCell(2);
   var numcell = recrow.insertCell(3);
   var editcell = recrow.insertCell(4);
   var scratchcell = recrow.insertCell(5);
   
   buttoncell.innerHTML = '<button id="RecButton' + id + '" onclick="CheckIn(\'' + id + '\', \'' + name + '\', \'' + club + '\', \'' + nation + '\')">Check-in</button>';
   namecell.innerHTML = name;
   clubcell.innerHTML = club;
   numcell.innerHTML = nation;
   editcell.innerHTML = '<button id="RecEditButton' + id + '" onclick="Edit(\'' + id + '\')">Edit</button>';
   scratchcell.innerHTML = '<button id="RecScratchButton' + id + '" onclick="UndoScratch(\'' + id + '\')">Undo Scratch</button>';
		
	GetFencers(id, 'scratch');
	
}
