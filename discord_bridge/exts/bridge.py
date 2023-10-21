import lifesaver
import aiohttp
from discord.ext import commands


def clean_content(content: str, **kwargs) -> str:
    """Make a string clean of mentions and not breaking codeblocks"""
    content = str(content)

    for user in kwargs.get("strip_mentions_from", []):
        content = content.replace(f"<@{user.id}>", "")
        content = content.replace(f"<@!{user.id}>", "")

    # only escape codeblocks when we are not normal_send
    # only escape single person pings when we are not normal_send
    if not kwargs.get("normal_send", False):
        content = content.replace("`", r"\`")
        content = content.replace("<@", "<@\u200b")
        content = content.replace("<#", "<#\u200b")

    # always escape role pings (@everyone) and @here
    content = content.replace("<@&", "<@&\u200b")
    content = content.replace("@here", "@\u200bhere")
    content = content.replace("@everyone", "@\u200beveryone")

    content = content.strip()
    return content


class Bridge(lifesaver.Cog):
    def __init__(self, bot):
        self.bot = bot
        self.session = aiohttp.ClientSession()

    async def cog_unload(self):
        await self.session.close()

    def for_bridge(self, message):
        return bool([m for m in message.mentions if m.id == self.bot.user.id])

    @commands.Cog.listener()
    async def on_message(self, msg):
        if msg.author == self.bot.user:
            return
        if not self.for_bridge(msg):
            return
        data = {
            "input_data": {
                "author": msg.author.name,
                "content": clean_content(
                    msg.content, strip_mentions_from=[self.bot.user]
                ),
                "channel_id": msg.channel.id,
            }
        }
        async with msg.channel.typing():
            async with self.session.post(
                "http://localhost:4000/api/v0/agent/call", json=data
            ) as resp:
                rjson = await resp.json()
                await msg.reply(rjson["reply"])


async def setup(bot):
    await bot.add_cog(Bridge(bot))
