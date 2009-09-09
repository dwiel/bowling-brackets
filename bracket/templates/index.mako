<script src="/js/jquery-1.3.2.min.js" type="text/javascript"></script>
<script src="/js/json2.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/style.css" />

<div id="names_col">
  <table id="names">
    <tr id="table_row-1">
      <th>
        Name
      </th>
      <th>
        # of brackets
      </th>
    </tr>
    <tr>
      <th>
        Total:
      </th>
      <th>
        <div id="total" /></div>
      </th>
    </tr>
  </table>
  <br>
  <hr>
  <br>
  <table>
    <tr>
      <td>Name:</td>
      <td><input type="text" id="name" /></td>
    </tr>
    <tr>
      <td># of Brackets:</td>
      <td><input type="text" id="number" /></td>
    </tr>
  </table>
  <a href="javascript:create_new_person()">add</a>
  <a href="javascript:clear()">clear</a><br>
  <br>
  <hr>
  <br>
  <table>
    <tr>
      <td># of people in each bracket:</td>
      <td><input type="text" id="bracket_size" value="8"/></td>
    </tr>
    <tr>
      <td># of brackets:</td>
      <td><input type="text" id="numbrackets" value="6"/></td>
    </tr>
  </table>
  <a href="javascript:make_bracket()">make bracket</a>
</div>
<div id="bracket_col">
  <div id="bracket_col_title"><b>Brackets<b></div>
  <div id="log" />
</div>


<script>
var numpeople = 0;

function log(data) {
  $('#log').append(data+'<br>');
}

function keys(array) {
  var _keys = [];
  for (var key in array) {
    if (array.hasOwnProperty(key)) {
      _keys.push(key);
    }
  }
  return _keys;
}

function indexOf(array, obj, fromIndex) {
  if (fromIndex == null) {
    fromIndex = 0;
  } else if (fromIndex < 0) {
    fromIndex = Math.max(0, array.length + fromIndex);
  }
  for (var i = fromIndex, j = array.length; i < j; i++) {
    if (array[i] === obj)
      return i;
  }
  return -1;
}

function create_new_person() {
  var name = $('#name').val();
  $.post('create_new_person?name='+name);
  add_person(name);
  
  $('#name').val('');
  $('#number').val('');
  $('#name').focus();
}

function add_person(name) {
  var people_ids = make_people_array_id();
  var names = keys(people_ids);
  names.push(name);
  names.sort();
  insertAfterIndex = indexOf(names, name) - 1;
  if(insertAfterIndex == -1) {
    insertAfterId = -1;
  } else {
    insertAfterId = people_ids[names[insertAfterIndex]];
  }

  row = '<tr class="table_row" id="table_row'+numpeople+'"><td><div class="name" id="name'+numpeople+'">'+name+'</div></td><td><input class="number"  value="'+$('#number').val()+'" id="number'+numpeople+'" /></td></tr>';
  // row = '<tr class="table_row" id="table_row'+numpeople+'"><td><input class="name"  value="'+name+'" id="name'+numpeople+'" /></td><td><input class="number"  value="'+$('#number').val()+'" id="number'+numpeople+'" /></td></tr>';
  $('#table_row'+insertAfterId).after( row );
  numpeople += 1;
  
  update_total();
}

function clear() {
  $('.number').each(function(_, ele) {
    $(ele).attr('value', '');
  });
  
  update_total();
}

function update_total() {
  var total = 0;
  $('.number').each(function (_, ele) {
    var val = $(ele).val();
    if(val) {
      total += parseInt(val);
    }
  });
  $('#total').html(total);
  var numbrackets = Math.floor(total / $('#bracket_size').val());
  var emptyspots = $('#bracket_size').val() - (total - numbrackets*$('#bracket_size').val());
  if(emptyspots != $('#bracket_size').val()) {
    $('#numbrackets').val(numbrackets + ' ('+emptyspots+')');
  } else {
    $('#numbrackets').val(numbrackets);
  }
}

function make_people_array() {
  var ppl = {};
  
  for(var i = 0; i < numpeople; ++i) {
    ppl[$('#name'+i).html()] = parseInt($('#number'+i).val());
  }

  return ppl;
}
  
function make_people_array_id() {
  var people = new Array();
  
  for(var i = 0; i < numpeople; ++i) {
    people[$('#name'+i).html()] = i;
  }
  
  return people;
}
  
var brackets = [];
var possible_positions = [];

function opponent(bracket_i, i) {
  if(i % 2 == 0) {
    return brackets[bracket_i][i+1];
  } else {
    return brackets[bracket_i][i-1];
  }
}

// return the possible positions left in the bracket
function make_possible_positions() {
  var bracket_size = $('#bracket_size').val();
  var numbrackets = $('#numbrackets').val();
  for(var bracket_i = 0; bracket_i < numbrackets; ++bracket_i) {
    var positions = [];
    var done_i = [];
    // first look for empty slots
    for(var i = 0; i < bracket_size; ++i) {
      log('bracket_i: '+bracket_i);
      if(brackets[bracket_i][i] == -1) {
        if(opponent(bracket_i, i) == -1) {
          done_i.push(i);
          positions.push({
            'bracket' : bracket_i,
            'position' : i,
            'opponent' : -1,
          });
        }
      }
    }
    
    // now look for any slot
    for(var i = 0; i < numbrackets; ++i) {
      if(brackets[bracket_i][i] == -1) {
        if(!(i in done_i)) {
          positions.push({
            'bracket' : bracket_i,
            'position' : i,
            'opponent' : opponent(bracket_i, i),
          });
        }
      }
    }
    
    possible_positions[bracket_i] = positions;
  }
}

function player_at(position) {
  return brackets[position['bracket']][position['position']];
}

function nonunique(so_far) {
  // count each player in so_far
  var counts = {};
  for(var player in so_far) {
    if(counts['player'] > 0) {
      counts['player'] += 1;
    } else {
      counts['player'] = 1;
    }
  }
  
  // find the maximum number of times one player occurs
  var max = 0;
  for(var key in counts) {
    if(key != -1) {
      if(counts[key] > max) {
        max = counts[key];
      }
    }
  }
  
  log('so_far: '+so_far);
  log('counts: '+counts);
  log('max: '+max);
  return max;
}

// given a new person, which are the best (bracket, position) pairs to minimize this new person playing the same person
function best(bracket_i, so_far, best_case){
  var numbrackets = $('#numbrackets').val();
  if(bracket_i == undefined) {
    // do some preprocessing
    make_possible_positions();
    log('possible_positions: '+possible_positions);
    
    // initialize recursive vars
    bracket_i = 0;
    so_far = [];
    best_case = numbrackets + 100;
  } else if(bracket_i == numbrackets) {
    if(nonunique(so_far) < best_case) {
      log(209);
      return {
        'best_case' : nonunique(so_far),
        'solution' : so_far,
      }
    }
  }
  
  log('possible_positions: '+JSON.stringify(possible_positions));
  this_ret = false;
  for(var position in possible_positions[bracket_i]) {
    log('position: '+position);
    var opp = player_at(possible_positions[bracket_i][position]);
//     if(opp != -1) {
      so_far.push(opp);
//     }
    if(nonunique(so_far) >= best_case) {
      log(221);
      return false;
    }
    ret = best(bracket_i + 1, so_far.slice(), best_case);
    if(ret) {
      best_case = ret['best_case'];
      this_ret = {
        'best_case' : best_case,
        'solution' : ret['solution'],
      };
    }
  }
  
  log(234);
  log(this_ret);
  return this_ret;
}

function initialize_brackets() {
  var numbrackets = $('#numbrackets').val();
  var bracket_size = $('#bracket_size').val();
  brackets = []
  for(var i = 0; i < numbrackets; ++i) {
    brackets[i] = [];
    for(var j = 0; j < bracket_size; ++j) {
      brackets[i][j] = -1;
    }
  }
}

//+ Jonas Raoni Soares Silva
//@ http://jsfromhell.com/array/shuffle [v1.0]

shuffle = function(o){ //v1.0
  for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
  return o;
};

function get_brackets_filled_positions() {
  var a = [];
  var bracket_size = $('#bracket_size').val();
  var numbrackets = $('#numbrackets').val();
  for(var i = 0; i < numbrackets; ++i) {
    a[i] = 0;
    for(var j = 0; j < bracket_size; ++j) {
      if(brackets[i][j] != -1) {
        a[i] += 1;
      }
    }
  }
  return a;
}

function random_brackets() {
  var a = [];
  var bracket_size = $('#bracket_size').val();
  var numbrackets = $('#numbrackets').val();
  var brackets_filled_positions = get_brackets_filled_positions();
  for(var i = 0; i < bracket_size; ++i) {
    for(var j = 0; j < numbrackets; ++j) {
      if(brackets_filled_positions[j] == i) {
        a.push(j);
      }
    }
  }
  // return shuffle(a);
  return a;
}

function random_positions() {
  var a = [];
  var bracket_size = $('#bracket_size').val();
  for(var i = 0; i < bracket_size; ++i) {
    a.push(i);
  }
  return shuffle(a);
}

function first_possible_pos_in_bracket(b, so_far) {
  var bracket_size = $('#bracket_size').val();
  // for each position in the bracket
  var randpositions = random_positions();
  for(var ii = 0; ii < bracket_size; ++ii) {
    var i = randpositions[ii];
    // if the position is open
    if(brackets[b][i] == -1) {
      // see if this opponent has already been played
      var found = false;
      var o = opponent(b, i);
      for(var x in so_far) {
        if(o == so_far[x]) {
          found = true;
        }
      }
      // if they haven't, we've found the spot
      if(found == false) {
        return i;
      }
    }
  }
  // there is no spot
  return -1;
}

function make_bracket() {
  for(var iter = 0; iter < 20; ++iter) {
    $('#log').html('');
    
    initialize_brackets();
    var people = make_people_array();
    
    for(name in people) {
      // log('name: '+name+', '+people[name]);
      
      // so_far is a list of opponents this person is already set to play - starts empty
      var so_far = [];
      // number of positions in all the brackets they have already
      // been placed
      var set_positions = 0;
      var randbrackets = random_brackets();
      // log('randbrackets.length: '+randbrackets.length);
      for(var bi = 0; bi < randbrackets.length; ++bi) {
        var b = randbrackets[bi];
        if(set_positions >= people[name]) {
          break;
        }
        // can we add this player to this bracket such that they dont play the same person twice?
        var pos = first_possible_pos_in_bracket(b, so_far);
        if(pos != -1) {
          // log(''+b+' '+pos+' '+name);
          brackets[b][pos] = name;
          var o = opponent(b, pos);
          if(o != -1) {
            so_far.push(o);
          }
          set_positions += 1;
        }
      }
      // TODO: if we couldn't get it so that they aren't ever
      // playing the same person twice, try for only playing one
      // person twice, etc
  //     log('name: '+name+', '+people[name]);
  //     log('set_positions ('+set_positions+') >= people[name] ('+people[name]+')');
  //     log('so_far');
  //     log(so_far);
    }
    
    var numbrackets = $('#numbrackets').val();
    var bracket_size = $('#bracket_size').val();
    var missing = 0;
    for(var i = 0; i < numbrackets; ++i) {
      for(var j = 0; j < bracket_size; ++j) {
        if(brackets[i][j] == -1) {
          missing++;
        }
      }
    }
    
    if(missing == 0) {
      break;
    }
  }
  
  if(missing != 0) {
    log('MISSING: ' + missing);
  }
  for(var i in brackets) {
    log('#'+(parseInt(i)+1));
    for(var j = 0; j < bracket_size / 2; ++j) {
      log('&nbsp;&nbsp;&nbsp;'+brackets[i][j*2]+' - '+brackets[i][j*2+1]);
    }
  }
}

// to do this right, make a search space which covers all possible brackets and where you have gone, then ...

$(document).ready(function () {
  var names = ${c.names};
  for(var i in names) {
    add_person(names[i]);
  }
  
  $('.number').change(function () {
    update_total();
  });
});

</script>