var editorVue,htmlCodeMirror, jsCodeMirror, cssCodeMirror;

$(function(){
  editorVue = initEditor('#code-wraper')

  $('body').mouseup(function(){
    $('body').unbind('mousemove')
    $('.window-cover').hide()
  })

  initCodeMirror()
})



function initEditor(id){
  var editor = new Vue({
    el: id,
    data: {
      p1: {w: 0, h: 100, ow: 0, oh: 0},
      p2: {w: 0, h: 100, ow: 0},
      p3: {w: 0, h: 100, ow: 0},
      p4: {h: 100, oh: 0},
      ox: 0,
      oy: 0
    }
  })
  
  // 初始化
  var basew = parseInt($(id).width() / 3)
  var baseh = parseInt(($(id).height() - 40) * 0.4)
  editor.p1.w = basew + 'px'
  editor.p1.h = baseh + 'px'
  editor.p2.w = basew + 'px'
  editor.p3.w = ($(id).width() - basew * 2 - 5 * 2) + 'px'
  editor.p4.h = (($(id).height() - 40) - baseh - 5) + 'px'


  
  // 横向移动
  editor.moveX = function(e, pleft, pright){
    editor.ox = e.clientX
    pleft.ow = pleft.w
    pright.ow = pright.w
    $('body').mousemove(function(me){
      var diff = me.clientX - editor.ox
      var leftw = parseInt(pleft.ow) + diff
      var rightw = parseInt(pright.ow) - diff
      if (leftw <= 50 || rightw <= 50) {return}
      pleft.w = leftw + 'px'
      pright.w = rightw  + 'px'
    })
  }

  // 纵向移动
  editor.moveY = function(e){
    $('.window-cover').show()
    var ptop = editor.p1
    var pbottom = editor.p4

    editor.oy = e.clientY
    ptop.oh = ptop.h
    pbottom.oh = pbottom.h
    $('body').mousemove(function(me){
      var diff = me.clientY - editor.oy
      var toph = parseInt(ptop.oh) + diff
      var bottomh = parseInt(pbottom.oh) - diff
      if (toph <= 50 || bottomh <= 50) {return}
      ptop.h = toph + 'px'
      pbottom.h = bottomh + 'px'
    })
  }
   
  // 预览
  editor.preview = function(){
    run_code()
  }




  return editor
}

function initCodeMirror(){
  htmlCodeMirror =  AddCodeMirror('#code-html', 'text/html') 
  jsCodeMirror = AddCodeMirror('#code-js', 'javascript')
  cssCodeMirror =  AddCodeMirror('#code-css', 'css')

  init_code()
}

function AddCodeMirror(textareaId, mode){
  return  CodeMirror.fromTextArea($(textareaId)[0],{
    //lineNumbers: true,
    mode: mode,
    matchBrackets: true,
    lineWrapping: true,
    autoCloseTags: true
  })
}


//- 初始化编辑器代码
function init_code(){
  var _html =  "<!DOCTYPE html>\n\
<html>\n\
<head>\n\
  <meta charset='utf-8' \/> \n\
<\/head>\n\
<body>\n\
  \n\
<\/body>\n\
<\/html>"; 
  
  setTimeout(function(){
    htmlCodeMirror.setValue(_html);
    jsCodeMirror.setValue('');
    cssCodeMirror.setValue('');
  }, 1)
}

//- 运行
function run_code(){
  var shtml = htmlCodeMirror.getValue()
  var sjs = jsCodeMirror.getValue()
  var scss = cssCodeMirror.getValue()

  var previewFrame = $('#preview')[0];
  var preview =  previewFrame.contentDocument ||  previewFrame.contentWindow.document;

  var _js = "<script type='text/javascript'>" + sjs + "<\/script>";
  var _css = "<style>" + scss + "</style>";
  var _html = shtml.replace(/(\s+)(<\/head>)/,'$1  ' + _js + _css+'$1$2');
  preview.open();
  preview.write(_html); 
  preview.close();

}