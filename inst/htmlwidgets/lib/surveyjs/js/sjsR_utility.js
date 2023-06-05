
// Adapted from https://surveyjs.io/form-library/examples/create-quiz-with-immediate-results/jquery
function sjsR_changeTitleCorrect(q, correctStr = "✅", incorrectStr = "❌"){
    if (!q || typeof q.correctAnswer === "undefined") return;

    const isCorrect = sjsR_isAnswerCorrect(q);
    if (!q.prevTitle) {
        q.prevTitle = q.title;
    }
    if (isCorrect === undefined) {
        q.title = q.prevTitle;
    }
    q.title =  q.prevTitle + ' ' + (isCorrect ? correctStr : incorrectStr);
    // This is annoying, but in order to rerender MathJax in titles, we need to
    // rerender the whole page (I don't see a way of getting the HTML element here)
    // Seems like overkill.
    if(typeof MathJax !== 'undefined'){
      MathJax.Hub.Typeset()
    }
}

// Adapted from https://surveyjs.io/form-library/examples/create-quiz-with-immediate-results/jquery
function sjsR_isAnswerCorrect (q) {
    const correctAnswer = q.correctAnswer;

    if (correctAnswer === "undefined" || q.isEmpty())
        return undefined;

    let givenAnswer = q.value;

    if(typeof correctAnswer === "object"){
        if(correctAnswer.type === "string" && correctAnswer.regex){
           return sjsR_checkString(givenAnswer, correctAnswer.regex);
        }else if(correctAnswer.type === "number" && correctAnswer.intervals){
           return sjsR_checkNumber(givenAnswer, correctAnswer.intervals);
        }else{
            throw new Error(`Bad object as correctAnswer in question ${q.name}: ${correctAnswer}.`);
        }
    }else{
        if (!Array.isArray(correctAnswer))
            return correctAnswer == givenAnswer;

        if (!Array.isArray(givenAnswer))
            givenAnswer = [givenAnswer];

        for (let i = 0; i < givenAnswer.length; i++) {
            if (correctAnswer.indexOf(givenAnswer[i]) < 0)
                return false;
        }
        return true;
    }
}

function sjsR_checkNumberSingle(answer, min, max, excL = false, excU = false){
	if(isNaN(answer)) return false;
	if((isNaN(min) && typeof min !== "undefined") ||
		(isNaN(max) && typeof max !== "undefined")){
    	throw new Error(`Nonnumeric values in min ("${min}") or max ("${max}") of correctAnswer.`);
    }
  if(isNaN(min)){
  	excL = false;
    min = Number.NEGATIVE_INFINITY;
   }
   if(isNaN(max)){
     excU = false;
     max = Number.POSITIVE_INFINITY;
   }

   if( ((min==max) && (max==answer)) && (!excL || !excU)) return true;
   if((answer < min) || ((answer == min) && excL)) return false;
   if((answer > max) || ((answer == max) && excU)) return false;
   return true;
}

function sjsR_checkNumber(answer, intervals){
	if(Array.isArray(intervals)){
  	for(var i=0;i<intervals.length;i++){
    	if(typeof intervals !== "object"){
      	throw new Error('Elements of "intervals" argument must by objects.');
      }
      if(
      	sjsR_checkNumberSingle(
      		answer,
        	intervals[i].min,
          intervals[i].max,
          intervals[i].excL,
          intervals[i].excU
          )
        ) return true;
    }
    return false;
  }else if(typeof intervals === "object"){
  	return sjsR_checkNumberSingle(answer, intervals.min, intervals.max, intervals.excL, intervals.excU);
  }
  throw new Error('Invalid number object in correctAnswer.');
}

function sjsR_checkStringSingle(answer, regex, flags = 'i', trim = true){
  const re = new RegExp(regex, flags);
  answer = trim ? String(answer).trim() : String(answer);
  return re.test(answer);
}

function sjsR_checkString(answer, regex){
  if(Array.isArray(regex)){
  	 return regex.map(el => {
  	   if(typeof el !== "object"){
      	 throw new Error('Elements of "regex" argument must be objects.');
       }
       return sjsR_checkStringSingle(answer, el.regex, el.flags, regex.trim);
  	 }).every(x=>x);
  }else if(typeof regex === "object"){
  	return sjsR_checkStringSingle(answer, regex.regex, regex.flags, regex.trim);
  }
  throw new Error('Invalid "regex" object in correctAnswer.');
}


