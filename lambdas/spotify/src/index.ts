import { Context, APIGatewayProxyResult, APIGatewayEvent } from "aws-lambda";
import axios from "axios";
import { CurrentPlayingTrackType, SpotifyAuthApiResponse } from "./types";
import "dotenv/config";

export const handler = async (
  event: APIGatewayEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  console.log(`Event: ${JSON.stringify(event, null, 2)}`);
  console.log(`Context: ${JSON.stringify(context, null, 2)}`);
  const getToken = async (): Promise<SpotifyAuthApiResponse> => {
    const params = new URLSearchParams();
    params.append("grant_type", "refresh_token");
    if (process.env.SPOTIFY_REFRESH_TOKEN != undefined) {
      params.append("refresh_token", process.env.SPOTIFY_REFRESH_TOKEN);
    }
    const headers = {
      Authorization: `Basic ${Buffer.from(
        `${process.env.SPOTIFY_CLIENT_ID}:${process.env.SPOTIFY_CLIENT_SECRET}`
      ).toString("base64")}`,
      "Content-Type": "application/x-www-form-urlencoded",
    };
    const res = await axios.post<SpotifyAuthApiResponse>(
      "https://accounts.spotify.com/api/token",
      params,
      {
        headers,
      }
    );
    return res.data;
  };

  const getCurrentPlayingTrack = async (
    accessToken: string
  ): Promise<Pick<CurrentPlayingTrackType, "item" | "is_playing">> => {
    const res = await axios.get<CurrentPlayingTrackType>(
      "https://api.spotify.com/v1/me/player/currently-playing",
      {
        headers: {
          "Content-Type": "application/json",
          "Accept-Language": "en",
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );
    return res.data;
  };

  const res = await getToken();
  const track = await getCurrentPlayingTrack(res.access_token);

  const result = {
    title: track.item.name,
    artist: track.item.artists[0].name,
  };
  console.log(JSON.stringify(result));
  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(result),
  };
};
