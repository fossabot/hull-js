/**
 * # Like Button
 *
 * Allow users to `like` an object. Likes are not connected to facebook or any other network
 * You can use this as "favorite", "starred", "want"... or of course "like".
 * It also shows the number of likes the object has.
 *
 * ## Examples
 *
 *     <div data-hull-widget="like_button@hull" data-hull-id="HULL_ID"></div>
 *     <div data-hull-widget="like_button@hull" data-hull-id="YOUR_UNIQUE_ID"></div>
 *     <div data-hull-widget="like_button@hull" data-hull-id="ANY_URL"></div>
 *
 * ## Options
 *
 * - `id`: Target object to show like button for
 *
 * ## Template
 *
 * - `like_button`: Main template. Has 3 states: Unliked, Liked and Working
 *
 */

 define({
  type: "Hull",

  templates: ["like_button"],

  working: false,

  datasources: {
    target: ':id',
    liked: function(){
      return this.api("me/liked/"+this.options.id);
    },
  },

  beforeRender:function(data){
    data.likes = data.target.stats.likes||0
    return data;
  },

  act: function(verb) {
    if (this.working) {
      return;
    }
    this.working = true;
    var self=this;
    var method = verb === 'unlike' ? 'delete' : 'post';
    self.likes++;
    self.liked=!self.liked;

    self.render(self.getTemplate(),{working:true, likes:self.likes, liked:self.liked});

    this.api(this.id + '/likes', method).success(function(likes) {
      self.likes=likes;

    }).fail(function(){
      self.likes--;
      self.liked=!self.liked;

    }).always(function(){
      self.working=false;
      self.render(self.getTemplate(),{working:self.working, liked:self.liked, likes:self.likes});

    });
  },

  actions: {
    like: function() {
      this.act('like');
    },
    unlike: function() {
      this.act('unlike');
    }
  }

});
