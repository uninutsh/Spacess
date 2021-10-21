changequote([[, ]])dnl
define(_long_comment,)dnl
_long_comment([[
void 
example_function (int x, int y)
{
  int x = sqrt (100);
  for (int i = 0; i < x; i++)
    {
      example_function (x * y, y + 2);
    }
  do
    {
      another_example_function ();
    }
  while ()
}]])dnl
#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>

#define MAX_ROWS 16
#define MAX_COLS 16

#define SUCCESS 0
#define ERROR 1

#define TEXTURE_WIDTH 512
#define TEXTURE_HEIGHT 256
#define MAX_TEXTURES_COUNT 64

#define TEXTURE_BACKGROUND 0

struct Camera
{
  double position[2];
};

struct Cell
{
  int position[2];
};

struct Room
{
  int size[2];
  struct Cell cells[MAX_ROWS][MAX_COLS];
};

struct GameManager
{
  bool running;
  SDL_Window *window;
  SDL_Renderer *renderer;
  SDL_Texture *texture;
  double texture_size_ratio;
  struct Camera camera;
  struct Room room;
  SDL_Texture *textures[MAX_TEXTURES_COUNT];
  int textures_count;
  int cell_size;
  SDL_Rect screen_rectangle;
};

struct GameManager manager;

bool
excess_width (double window_size_ratio)
{
  if (window_size_ratio > manager.texture_size_ratio)
    {
      return true;
    }
  return false;
}

// ww / wh = w / h = tex_ratio => w = tex_ratio * h => h = w / tex_ratio 

void
calculate_screen_rectangle (int window_width, int window_height)
{
  double window_size_ratio = window_width / (double)window_height;
  if (excess_width (window_size_ratio))
    {
      manager.screen_rectangle.y = 0;
      manager.screen_rectangle.h = window_height;
      manager.screen_rectangle.w = window_height * manager.texture_size_ratio;
      int excess = window_width - manager.screen_rectangle.w;
      manager.screen_rectangle.x = excess / 2;
    }
  else
    {
      manager.screen_rectangle.x = 0;
      manager.screen_rectangle.w = window_width;
      manager.screen_rectangle.h = window_width / manager.texture_size_ratio;
      int excess = window_height - manager.screen_rectangle.h;
      manager.screen_rectangle.y = excess / 2;
    }
}

void
draw_room (struct Room *room, struct Camera *camera, SDL_Renderer *renderer)
{
  for (int ry = 0; ry < room->size[1]; ry++)
   {
     int y = ry * manager.cell_size - camera->position[1];
     for (int rx = 0; rx < room->size[0]; rx++)
      {
        int x = rx * manager.cell_size - camera->position[0];
        SDL_Rect destination;
        destination.x = x;
        destination.y = y;
        destination.w = manager.cell_size;
        destination.h = manager.cell_size;
        SDL_RenderCopy (renderer, manager.textures[TEXTURE_BACKGROUND], NULL, &destination);
      }
   }
}

int
load_texture (char *path)
{
  assert (manager.renderer != NULL);
  assert (manager.textures_count < MAX_TEXTURES_COUNT);
  SDL_Surface *surface;
  surface = IMG_Load (path);
  if (surface == NULL) 
    {
      fprintf (stderr, "IMG_Load: %s\n", IMG_GetError ());
      return ERROR;
    }
  manager.textures[manager.textures_count] = SDL_CreateTextureFromSurface (manager.renderer, surface);
  if (manager.textures[manager.textures_count] == NULL)
  {
    fprintf (stderr, "Could not load texture(%s): %s\n",path, SDL_GetError ());
    return ERROR;
  }
  manager.textures_count++;
  SDL_FreeSurface (surface);
  return SUCCESS;
}

int
load_textures ()
{
  manager.textures_count = 0;
  if (load_texture("resources/sprites/bg0x0.png") == ERROR)
   {
     return ERROR;
   }
  return SUCCESS;
}

int
initialize_room (struct Room *room, int width, int height)
{
  room->size[0] = width;
  room->size[1] = height;
  for (int y = 0; y < height; y++)
   {
     for (int x =0; x < width; x++)
      {
        struct Cell *cell = &room->cells[y][x];
        cell->position[0] = x;
        cell->position[1] = y;
      }
   }
   return SUCCESS;
}

int
initialize_camera (struct Camera *camera, double x, double y)
{
  camera->position[0] = x;
  camera->position[1] = y;
  return SUCCESS;
}

int
initialize()
{
  manager.cell_size = 32;
  if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_EVENTS) != 0)
    {
      fprintf (stderr, "Unable to initialize SDL: %s", SDL_GetError ());
      return ERROR;
    }
  int flags = IMG_INIT_PNG;
  int initted = IMG_Init (flags);
  if ((initted & flags) != flags)
    {
      fprintf (stderr, "IMG_Init: Failed to init required image formats support!\n");
      fprintf (stderr, "IMG_Init: %s\n", IMG_GetError ());
      return ERROR;
    }
  manager.window = SDL_CreateWindow("Spacess", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1024, 512, SDL_WINDOW_HIDDEN | SDL_WINDOW_RESIZABLE);
  if (manager.window == NULL)
    {
      fprintf (stderr, "Could not create window: %s\n", SDL_GetError ());
      return ERROR;
    }
  manager.renderer = SDL_CreateRenderer (manager.window, -1, 0);
  if (manager.renderer == NULL)
    {
      fprintf (stderr, "Could not create renderer: %s\n", SDL_GetError ());
      return ERROR;
    }  
  manager.texture = SDL_CreateTexture (manager.renderer, SDL_PIXELFORMAT_UNKNOWN, SDL_TEXTUREACCESS_TARGET, TEXTURE_WIDTH, TEXTURE_HEIGHT);
  if (manager.texture == NULL)
    {
      fprintf (stderr, "Could not create texture: %s\n", SDL_GetError ());
      return ERROR;
    }
  manager.texture_size_ratio = TEXTURE_WIDTH / (double)TEXTURE_HEIGHT;
  calculate_screen_rectangle (1024, 512);
  if (initialize_room (&manager.room, 12, 8) == ERROR)
    {
      return ERROR;
    }
  if (initialize_camera (&manager.camera, 0, 0) == ERROR)
    {
      return ERROR;
    }
  if (load_textures () == ERROR)
    {
      return ERROR;
    }
  return SUCCESS;
}

int
start()
{
  SDL_ShowWindow (manager.window);
  manager.running = true;
  while (manager.running)
    {
      int ticks_a = SDL_GetTicks();
      SDL_SetRenderTarget (manager.renderer, manager.texture);
      SDL_SetRenderDrawColor(manager.renderer, 255, 255, 255, 255);
      SDL_RenderClear (manager.renderer);
      draw_room(&manager.room, &manager.camera, manager.renderer);
      SDL_SetRenderTarget (manager.renderer, NULL);
      SDL_SetRenderDrawColor(manager.renderer, 0, 0, 0, 255);
      SDL_RenderClear (manager.renderer);
      SDL_RenderCopy (manager.renderer, manager.texture, NULL, &manager.screen_rectangle);
      SDL_RenderPresent (manager.renderer);

      SDL_Event event;
      while (SDL_PollEvent (&event) > 0)
        {
          switch (event.type)
            {
            case SDL_QUIT:
              manager.running = false;
              return SUCCESS;
            case SDL_WINDOWEVENT:
              //fprintf (stdout, "SDL_WINDOWEVENT\n");fflush (stdout);
              switch (event.window.event)
                {
                  case SDL_WINDOWEVENT_SIZE_CHANGED:
                    //fprintf (stdout, "SDL_WINDOWEVENT_SIZE_CHANGED (%i, %i)\n", event.window.data1, event.window.data2);fflush (stdout);
                    calculate_screen_rectangle (event.window.data1, event.window.data2);
                    break;
                }
              break;
            }
        }
      //manager.camera.position[0] += 0.25;manager.camera.position[1] += 0.125;
      int ticks_b = SDL_GetTicks();
      int ticks_elpased = ticks_b - ticks_a;
      int ticks_to_delay = 16 - ticks_elpased;
      if (ticks_to_delay > 0)
        {
          SDL_Delay (ticks_to_delay);
        }
    }
  return SUCCESS;
}

void
free_textures ()
{
  for (int i = 0; i < manager.textures_count; i++)
    {
      SDL_DestroyTexture (manager.textures[i]);
    }
}

void
quit ()
{
  free_textures ();
  SDL_DestroyTexture (manager.texture);
  SDL_DestroyRenderer (manager.renderer);
  SDL_DestroyWindow (manager.window);
  IMG_Quit ();
  SDL_Quit ();
}

int
main(int argc, char *argv[])
{
  int i = initialize ();
  if (i == ERROR)
    {
      quit ();
      return i;
    }
  i = start ();
  quit ();
  return i;
}